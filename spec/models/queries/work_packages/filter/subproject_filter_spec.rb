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

describe Queries::WorkPackages::Filter::SubprojectFilter, type: :model do
  it_behaves_like 'basic query filter' do
    let(:order) { 13 }
    let(:type) { :list }
    let(:class_key) { :subproject_id }
    let(:name) { I18n.t('query_fields.subproject_id') }

    describe '#available?' do
      context 'with a project and that project not being a leaf
               and the project having visible descendants' do
        before do
          allow(project)
            .to receive(:leaf?)
            .and_return false
          allow(project)
            .to receive_message_chain(:descendants, :visible, :exists?)
            .and_return true
        end

        it 'is available' do
          expect(instance).to be_available
        end
      end

      context 'without a project' do
        let(:project) { nil }

        it 'is unavailable' do
          expect(instance).to_not be_available
        end
      end

      context 'with a project and that project is a leaf' do
        before do
          allow(project)
            .to receive(:leaf?)
            .and_return true
        end

        it 'is unavailable' do
          expect(instance).to_not be_available
        end
      end

      context 'with a project and that project not being a leaf
               but the user not seeing any of the descendants' do
        before do
          allow(project)
            .to receive(:leaf?)
            .and_return false
          allow(project)
            .to receive_message_chain(:descendants, :visible, :exists?)
            .and_return false
        end

        it 'is unavailable' do
          expect(instance).to_not be_available
        end
      end
    end

    describe '#allowed_values' do
      let(:subproject1) { FactoryGirl.build_stubbed(:project) }
      let(:subproject2) { FactoryGirl.build_stubbed(:project) }

      before do
        allow(project)
          .to receive_message_chain(:descendants, :visible)
          .and_return [subproject1, subproject2]
      end

      it 'returns a list of all visible descendants' do
        expect(instance.allowed_values).to match_array [[subproject1.name, subproject1.id.to_s],
                                                        [subproject2.name, subproject2.id.to_s]]
      end
    end

    describe '#ar_object_filter?' do
      it 'is true' do
        expect(instance)
          .to be_ar_object_filter
      end
    end

    describe '#value_objects' do
      let(:subproject1) { FactoryGirl.build_stubbed(:project) }
      let(:subproject2) { FactoryGirl.build_stubbed(:project) }

      before do
        allow(project)
          .to receive_message_chain(:descendants, :visible)
          .and_return([subproject1, subproject2])

        instance.values = [subproject1.id.to_s, subproject2.id.to_s]
      end

      it 'returns an array of projects' do
        expect(instance.value_objects)
          .to match_array([subproject1, subproject2])
      end
    end
  end
end
