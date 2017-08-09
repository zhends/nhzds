#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.

require 'spec_helper'

describe Scm::CreateManagedRepositoryService do
  let(:user) { FactoryGirl.build(:user) }
  let(:project) { FactoryGirl.build(:project) }

  let(:repository) { FactoryGirl.build(:repository_subversion) }
  subject(:service) { Scm::CreateManagedRepositoryService.new(repository) }

  let(:config) { {} }

  before do
    allow(OpenProject::Configuration).to receive(:[]).and_call_original
    allow(OpenProject::Configuration).to receive(:[]).with('scm').and_return(config)
  end

  shared_examples 'does not create a filesystem repository' do
    it 'does not create a filesystem repository' do
      expect(repository.managed?).to be false
      expect(service.call).to be false
    end
  end

  context 'with no managed configuration' do
    it_behaves_like 'does not create a filesystem repository'
  end

  context 'with managed repository' do
    # Must not .create a managed repository, or it will call this service itself!
    let(:repository) {
      repo = Repository::Subversion.new(scm_type: :managed)
      repo.project = project
      repo
    }

    context 'but no managed config' do
      it 'does not create a filesystem repository' do
        expect(repository.managed?).to be true
        expect(service.call).to be false
      end
    end
  end

  context 'with managed local config' do
    include_context 'with tmpdir'
    let(:config) {
      {
        subversion: { manages: File.join(tmpdir, 'svn') },
        git: { manages: File.join(tmpdir, 'git') }
      }
    }

    let(:repository) {
      repo = Repository::Subversion.new(scm_type: :managed)
      repo.project = project
      repo.configure(:managed, nil)
      repo
    }

    before do
      allow_any_instance_of(Scm::CreateLocalRepositoryJob)
        .to receive(:repository).and_return(repository)
      allow_any_instance_of(Scm::CreateRemoteRepositoryJob)
        .to receive(:repository).and_return(repository)
    end

    it 'creates the repository' do
      expect(service.call).to be true
      expect(File.directory?(repository.root_url)).to be true
    end

    context 'with pre-existing path on filesystem' do
      before do
        allow(File).to receive(:directory?).and_return(true)
      end

      it 'does not create the repository' do
        expect(service.call).to be false
        expect(service.localized_rejected_reason)
          .to eq(I18n.t('repositories.errors.exists_on_filesystem'))
      end
    end

    context 'with a permission error occurring in the Job' do
      before do
        allow(Scm::CreateLocalRepositoryJob)
          .to receive(:new).and_raise(Errno::EACCES)
      end

      it 'returns the correct error' do
        expect(service.call).to be false
        expect(service.localized_rejected_reason)
          .to eq(I18n.t('repositories.errors.path_permission_failed',
                        path: repository.root_url))
      end
    end

    context 'with an OS error occurring in the Job' do
      before do
        allow(Scm::CreateLocalRepositoryJob)
          .to receive(:new).and_raise(Errno::ENOENT)
      end

      it 'returns the correct error' do
        expect(service.call).to be false
        expect(service.localized_rejected_reason)
          .to include('An error occurred while accessing the repository in the filesystem')
      end
    end
  end

  context 'with managed remote config', webmock: true do
    let(:url) { 'http://myreposerver.example.com/api/' }
    let(:config) {
      {
        subversion: { manages: url }
      }
    }

    let(:repository) {
      repo = FactoryGirl.build(:repository_subversion, scm_type: :managed)
      repo.project = project
      repo.configure(:managed, nil)
      repo
    }

    it 'detects the remote config' do
      expect(repository.class.managed_remote.to_s).to eq(url)
      expect(repository.class).to be_manages_remote
    end

    context 'with a remote callback' do
      let(:returned_url) { 'file:///tmp/some/url/to/repo' }
      let(:root_url) { '/tmp/some/url/to/repo' }
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: { url: returned_url, path: root_url }.to_json
          )
      end

      shared_examples 'calls the callback' do
        before do
          # Avoid setting up a second call to the remote during save
          # since we only templated the repository, not created one!
          expect(repository).to receive(:save).and_return(true)
        end

        it do
          expect(Scm::CreateRemoteRepositoryJob)
            .to receive(:new).and_call_original

          expect(service.call).to be true
          expect(repository.root_url).to eq(root_url)
          expect(repository.url).to eq(returned_url)

          expect(WebMock)
            .to have_requested(:post, url)
            .with(body: hash_including(action: 'create'))
        end
      end

      context 'with http' do
        it_behaves_like 'calls the callback'
      end

      context 'with https' do
        let(:url) { 'https://myreposerver.example.com/api/' }
        let(:config) {
          {
            subversion: { manages: url, insecure: insecure }
          }
        }

        let(:job) { Scm::CreateRemoteRepositoryJob.new(repository, perform_now: true) }

        context 'with insecure option' do
          let(:insecure) { true }

          it_behaves_like 'calls the callback'
          it 'uses the insecure option' do
            expect(job.send(:configured_verification)).to eq(OpenSSL::SSL::VERIFY_NONE)
          end
        end

        context 'without insecure option' do
          let(:insecure) { false }

          it 'uses the insecure option' do
            expect(job.send(:configured_verification)).to eq(OpenSSL::SSL::VERIFY_PEER)
          end
        end
      end
    end

    context 'with a faulty remote callback' do
      before do
        stub_request(:post, url)
          .to_return(status: 400, body: { success: false, message: 'An error occurred' }.to_json)
      end

      it 'calls the callback' do
        expect(Scm::CreateRemoteRepositoryJob)
          .to receive(:new).and_call_original

        expect(service.call).to be false
        expect(service.localized_rejected_reason)
          .to eq("Calling the managed remote failed with message 'An error occurred' (Code: 400)")
        expect(WebMock)
          .to have_requested(:post, url)
                .with(body: hash_including(action: 'create'))
      end
    end
  end
end
