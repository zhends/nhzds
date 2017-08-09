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
require 'features/projects/projects_page'

describe 'user deletion: ', type: :feature, js: true do
  before do
    page.set_rack_session(user_id: current_user.id)
  end

  context 'regular user' do
    let(:current_user) { FactoryGirl.create :user }

    it 'can delete their own account', selenium: true do
      Setting.users_deletable_by_self = 1
      visit delete_my_account_info_path

      fill_in 'login_verification', with: current_user.login
      click_on 'Delete'

      page.driver.browser.switch_to.alert.accept

      expect(page).to have_content 'Account successfully deleted'
      expect(current_path).to eq '/login'
    end

    it 'cannot delete their own account if the settings forbid it' do
      Setting.users_deletable_by_self = 0
      visit my_account_path

      within '#main-menu' do
        expect(page).to_not have_content 'Delete account'
      end
    end
  end

  context 'admin user' do
    let!(:user) { FactoryGirl.create :user }
    let(:current_user) { FactoryGirl.create :admin }

    it 'can delete other users if the setting permitts it', selenium: true do
      Setting.users_deletable_by_admins = 1
      visit edit_user_path(user)

      expect(page).to have_content "#{user.firstname} #{user.lastname}"

      click_on 'Delete'
      fill_in 'login_verification', with: user.login
      click_on 'Delete'

      page.driver.browser.switch_to.alert.accept

      expect(page).to have_content 'Account successfully deleted'
      expect(current_path).to eq '/users'
    end

    it 'cannot delete other users if the settings forbid it' do
      Setting.users_deletable_by_admins = 0
      visit edit_user_path(user)

      expect(page).to_not have_content 'Delete account'
    end

    it 'can change the deletablilty settings' do
      Setting.users_deletable_by_admins = 0
      Setting.users_deletable_by_self = 0

      visit settings_path(tab: 'users')

      find(:css, "#settings_users_deletable_by_admins").set(true)
      find(:css, "#settings_users_deletable_by_self").set(true)

      within '#tab-content-users' do
        click_on  'Save'
      end

      expect(Setting.users_deletable_by_admins?).to eq true
      expect(Setting.users_deletable_by_self?).to eq true
    end
  end
end
