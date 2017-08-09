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

RSpec.feature 'Keep current details tab', js: true, selenium: true do
  let(:user) { FactoryGirl.create(:admin) }
  let(:project) { FactoryGirl.create(:project) }
  let!(:wp1) { FactoryGirl.create(:work_package, project: project) }
  let!(:wp2) { FactoryGirl.create(:work_package, project: project) }

  let(:wp_table) { Pages::WorkPackagesTable.new(project) }
  let(:split) { Pages::WorkPackagesTable.new(project) }

  before do
    login_as(user)
    wp_table.visit!
  end

  scenario 'Remembers the tab while navigating the page' do
    wp_table.expect_work_package_listed(wp1)
    wp_table.expect_work_package_listed(wp2)

    # Open details pane through button
    wp_split1 = wp_table.open_split_view(wp1)
    wp_split1.expect_subject
    wp_split1.visit_tab! :activity

    wp_split2 = wp_table.open_split_view(wp2)
    wp_split2.expect_subject
    wp_split2.expect_tab :activity
    wp_split2.visit_tab! :relations

    # Open first WP by click on table
    wp_table.click_on_row(wp1)
    wp_split1.expect_subject
    wp_split1.expect_tab :relations

    # open work package full screen by button
    wp_full = wp_split1.switch_to_fullscreen
    wp_full.expect_tab :relations

    page.evaluate_script('window.history.back()')
    wp_split1.expect_tab :relations

    # Assert that overview tab is mapped to activity in show
    wp_split1.visit_tab! :overview
    wp_split1.expect_tab :overview

    wp_split1.switch_to_fullscreen
    wp_full.expect_tab :activity
    wp_full.ensure_page_loaded
  end
end
