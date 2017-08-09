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

shared_examples_for 'valid preview' do
  render_views

  before do
    put :preview, params: preview_params
  end

  it { expect(response).to render_template('common/preview') }

  it 'renders all texts' do
    preview_texts.each do |text|
      expect(response.body).to have_selector('fieldset.preview', text: text)
    end
  end
end

shared_examples_for 'authorizes object access' do
  let(:unauthorized_user) { FactoryGirl.create(:user) }

  before do
    allow(User).to receive(:current).and_return(unauthorized_user)

    put :preview, params: preview_params
  end

  it { expect(response.status).to eq(403) }
end
