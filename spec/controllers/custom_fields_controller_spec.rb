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

describe CustomFieldsController, type: :controller do
  let(:custom_field) { FactoryGirl.build(:custom_field) }

  before do
    allow(@controller).to receive(:authorize)
    allow(@controller).to receive(:check_if_login_required)
    allow(@controller).to receive(:require_admin)
  end

  describe 'POST edit' do
    before do
      allow(CustomField).to receive(:find).and_return(custom_field)
    end

    describe 'WITH all ok params' do
      let(:params) do
        {
          'custom_field' => { 'name' => 'Issue Field' }
        }
      end

      before do
        put :update, params: params
      end

      it 'works' do
        expect(response).to be_redirect
        expect(custom_field.name).to eq('Issue Field')
      end
    end
  end

  describe 'POST new' do
    describe 'WITH empty name param' do
      let(:params) do
        {
          'type' => 'WorkPackageCustomField',
          'custom_field' => {
            'name' => '',
            'field_format' => 'string'
          }
        }
      end

      before do
        post :create, params: params
      end

      it 'responds with error' do
        expect(response).to render_template 'new'
        expect(assigns(:custom_field).errors.messages[:name].first).to eq("can't be blank.")
      end
    end

    describe 'WITH all ok params' do
      let(:params) do
        {
          'type' => 'WorkPackageCustomField',
          'custom_field' => {
            'name' => 'field',
            'field_format' => 'string'
          }
        }
      end

      before do
        post :create, params: params
      end

      it 'responds ok' do
        expect(response.status).to eq(302)
        expect(assigns(:custom_field).name).to eq('field')
      end
    end
  end
end
