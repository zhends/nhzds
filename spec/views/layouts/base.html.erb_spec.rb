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

describe 'layouts/base', type: :view do
  # This is to make `visit` available. It might be already included by the time
  # we reach this spec, but for running this spec alone we need it here. Best
  # of both worlds.
  include Capybara::DSL

  include Redmine::MenuManager::MenuHelper
  helper Redmine::MenuManager::MenuHelper
  let!(:user) { FactoryGirl.create :user }
  let!(:anonymous) { FactoryGirl.create(:anonymous) }

  before do
    allow(view).to receive(:current_menu_item).and_return('overview')
    allow(view).to receive(:default_breadcrumb)
    allow(controller).to receive(:default_search_scope)
    allow(view)
      .to receive(:render_to_string)
  end

  describe 'projects menu visibility' do
    context 'when the user is not logged in' do
      before do
        allow(User).to receive(:current).and_return anonymous
        allow(view).to receive(:current_user).and_return anonymous
        render
      end

      it 'the projects menu should not be displayed' do
        expect(rendered).not_to have_text('Select a project')
      end
    end

    context 'when the user is logged in' do
      before do
        allow(User).to receive(:current).and_return user
        allow(view).to receive(:current_user).and_return user
        render
      end

      it 'the projects menu should be displayed' do
        expect(rendered).to have_text('Select a project')
      end
    end
  end

  describe 'Sign in button' do
    before do
      allow(User).to receive(:current).and_return anonymous
      allow(view).to receive(:current_user).and_return anonymous
    end

    context 'with omni_auth_direct_login disabled' do
      before do
        render
      end

      it 'shows the login drop down menu' do
        expect(rendered).to have_selector('div#nav-login-content', visible: false)
      end
    end

    context 'with omni_auth_direct_login enabled',
             with_config: { omniauth_direct_login_provider: 'some_provider' } do

      before do
        render
      end

      it 'shows just a sign-in link, no menu' do
        expect(rendered).to have_selector "a[href='/login']"
        expect(rendered).not_to have_selector 'div#nav-login-content'
      end
    end
  end

  describe 'login form' do
    before do
      allow(User).to receive(:current).and_return anonymous
      allow(view).to receive(:current_user).and_return anonymous
    end

    context 'with password login enabled' do
      before do
        render
      end

      it 'shows a login form' do
        expect(rendered).to include 'Login'
        expect(rendered).to include 'Password'
      end
    end

    context 'with password login disabled' do
      before do
        allow(OpenProject::Configuration).to receive(:disable_password_login?).and_return(true)
        render
      end

      it 'shows no password login form' do
        expect(rendered).not_to include 'Login'
        expect(rendered).not_to include 'Password'
      end
    end
  end

  describe 'icons' do
    before do
      allow(User).to receive(:current).and_return anonymous
      allow(view).to receive(:current_user).and_return anonymous
      render
    end

    it 'renders main favicon' do
      expect(rendered).to have_selector(
        "link[type='image/x-icon'][href*='#{OpenProject::Design.favicon_asset_path}']",
        visible: false
      )
    end

    it 'renders apple icons' do
      expect(rendered).to have_selector(
        "link[type='image/png'][href='/assets/apple-touch-icon-120x120.png']",
        visible: false
      )
    end

    # We perform a get request against the icons to ensure they are there (and
    # avoid 404 errors in production). Should you continue to see 404s in production,
    # ensure your asset cache is not stale.

    # We do this here as opposed to a request spec to 1. keep icon specs contained
    # in one place, and 2. the view itself makes this request, so this is an appropriate
    # location for it.
    it 'icons actually exist' do
      visit 'assets/favicon.ico'
      expect(page.status_code).to eq(200)

      visit 'apple-touch-icon-120x120.png'
      expect(page.status_code).to eq(200)
    end
  end

  describe "inline custom styles" do
    let(:a_token) { EnterpriseToken.new }

    before do
      allow(User).to receive(:current).and_return anonymous
      allow(view).to receive(:current_user).and_return anonymous
    end

    context "EE is active and styles are present" do
      let(:custom_style) { CustomStyle.new }
      let(:primary_color) { FactoryGirl.create :"design_color_primary-color" }

      before do
        allow(EnterpriseToken).to receive(:allows_to?).with(:define_custom_style).and_return(true)
        allow(CustomStyle).to receive(:current).and_return(custom_style)
      end

      it "contains inline CSS block with those styles." do
        render
        expect(response).to render_template partial: 'custom_styles/_inline_css'
      end

      it "renders CSS4 variables" do
        custom_style.save
        primary_color
        render
        expect(DesignColor.overwritten.size).to eq(1)
        expect(response).to render_template partial: 'custom_styles/_inline_css'
        expect(rendered).to match /--primary-color:\s*#{primary_color.get_hexcode}/
      end
    end

    context "EE is active and styles are not present" do
      before do
        allow(EnterpriseToken).to receive(:current).and_return(a_token)
        allow(a_token).to receive(:expired?).and_return(false)
        allow(a_token).to receive(:allows_to?).with(:define_custom_style).and_return(true)
        allow(CustomStyle).to receive(:current).and_return(nil)

        render
      end

      it "does not contain an inline CSS block for styles." do
        expect(response).to_not render_template partial: 'custom_styles/_inline_css'
      end
    end

    context "EE does not allow custom styles" do
      before do
        allow(EnterpriseToken).to receive(:current).and_return(a_token)
        allow(a_token).to receive(:expired?).and_return(false)
        allow(a_token).to receive(:allows_to?).with(:define_custom_style).and_return(false)

        render
      end

      it "does not contain an inline CSS block for styles." do
        expect(response).to_not render_template partial: 'custom_styles/_inline_css'
      end
    end

    context "no EE present" do
      before do
        allow(EnterpriseToken).to receive(:current).and_return(nil)

        render
      end

      it "does not contain an inline CSS block for styles." do
        expect(response).to_not render_template partial: 'custom_styles/_inline_css'
      end
    end
  end
end
