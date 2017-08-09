#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
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
#++

require 'spec_helper'
require 'features/repositories/repository_settings_page'
require 'features/support/components/danger_zone'

describe 'Repository Settings', type: :feature, js: true do
  let(:current_user) { FactoryGirl.create (:admin) }
  let(:project) { FactoryGirl.create(:project) }
  let(:settings_page) { RepositorySettingsPage.new(project) }
  let(:dangerzone) { DangerZone.new(page) }

  # Allow to override configuration values to determine
  # whether to activate managed repositories
  let(:enabled_scms) { %w[subversion git] }
  let(:config) { nil }

  before do
    allow(User).to receive(:current).and_return current_user
    allow(Setting).to receive(:enabled_scm).and_return(enabled_scms)

    allow(OpenProject::Configuration).to receive(:[]).and_call_original
    allow(OpenProject::Configuration).to receive(:[]).with('scm').and_return(config)

    allow(project).to receive(:repository).and_return(repository)
    settings_page.visit_repository_settings
  end

  shared_examples 'manages the repository' do |type|
    it 'displays the repository' do
      expect(page).to have_selector('select[name="scm_vendor"]')
      expect(find("#attributes-group--content-#{type}", visible: true))
        .not_to be_nil
    end

    it 'deletes the repository' do
      expect(Repository.exists?(repository.id)).to be true

      if type == 'managed'
        find('a.icon-delete', text: I18n.t(:button_delete)).click

        dangerzone = DangerZone.new(page)

        expect(page).to have_selector(dangerzone.container_selector)
        expect(dangerzone.disabled?).to be true

        dangerzone.confirm_with('definitely not the correct value')
        expect(dangerzone.disabled?).to be true

        dangerzone.confirm_with(project.identifier)
        expect(dangerzone.disabled?).to be false

        dangerzone.danger_button.click
      else
        find('a.icon-remove', text: I18n.t(:button_remove)).click
        expect(page).to have_selector('.notification-box.-warning')
        find('a', text: I18n.t(:button_remove)).click
      end

      vendor = find('select[name="scm_vendor"]')
      expect(vendor).not_to be_nil
      expect(vendor.value).to be_empty

      selected = vendor.find('option[selected]')
      expect(selected.text).to eq('--- Please select ---')
      expect(selected[:disabled]).to be_truthy
      expect(selected[:selected]).to be_truthy

      # Project should have no repository
      expect(Repository.exists?(repository.id)).to be false
    end
  end

  shared_examples 'manages the repository with' do |name, type, repository_type, project_name|
    let(:repository) {
      FactoryGirl.create("repository_#{name}".to_sym,
                         scm_type: type,
                         project: project)
    }
    it_behaves_like 'manages the repository', type
  end

  it_behaves_like 'manages the repository with', 'subversion', 'existing', 'Subversion - Repository', 'project'
  it_behaves_like 'manages the repository with', 'git', 'local', 'Git - Repository', 'project'

  context 'managed repositories' do
    context 'local' do
      include_context 'with tmpdir'
      let(:config) {
        {
          subversion: { manages: File.join(tmpdir, 'svn') },
          git: { manages: File.join(tmpdir, 'git') }
        }
      }

      let(:repository) {
        repo = Repository.build(
          project,
          managed_vendor,
          # Need to pass AC params here manually to simulate a regular repository build
          ActionController::Parameters.new({}),
          :managed
        )

        repo.save!
        repo
      }

      context 'Subversion' do
        let(:managed_vendor) { :subversion }
        it_behaves_like 'manages the repository', 'managed'
      end

      context 'Git' do
        let(:managed_vendor) { :git }
        it_behaves_like 'manages the repository', 'managed'
      end
    end

    context 'remote', webmock: true do
      let(:url) { 'http://myreposerver.example.com/api/' }
      let(:config) {
        {
          git: { manages: url }
        }
      }
      let(:managed_vendor) { :git }
      let(:repository) {
        repo = Repository.build(
          project,
          managed_vendor,
          # Need to pass AC params here manually to simulate a regular repository build
          ActionController::Parameters.new({}),
          :managed
        )

        stub_request(:post, url)
          .to_return(status: 200,
                     body: { success: true, url: 'file:///foo/bar' }.to_json)

        repo.save!
        repo
      }
      it_behaves_like 'manages the repository', 'managed'
    end
  end

  describe 'update repositories' do
    let(:repository) {
      FactoryGirl.create(:repository_subversion,
                         scm_type: :existing,
                         project: project)
    }

    it 'can set login and password' do
      fill_in('repository[login]', with: 'foobar')
      fill_in('repository_password', with: 'password')

      click_button(I18n.t(:button_save))
      expect(page).to have_selector('[name="repository[login]"][value="foobar"]')
      expect(page).to have_selector('.flash',
                                    text: I18n.t('repositories.update_settings_successful'))
    end
  end
end
