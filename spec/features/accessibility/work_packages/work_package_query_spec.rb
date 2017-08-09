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
require 'features/work_packages/work_packages_page'

describe 'Work package index accessibility', type: :feature, selenium: true do
  let(:user) { FactoryGirl.create(:admin) }
  let(:project) { FactoryGirl.create(:project) }
  let(:work_package) { FactoryGirl.create(:work_package, project: project) }
  let(:work_packages_page) { WorkPackagesPage.new(project) }
  let(:sort_ascending_selector) { '.icon-sort-ascending' }
  let(:sort_descending_selector) { '.icon-sort-descending' }

  def visit_index_page
    work_packages_page.visit_index
    # ensure the page is loaded before expecting anything
    expect(page).to have_selector('#operators-status', visible: false),
                    'Page was not fully loaded'
  end

  before do
    login_as(user)

    work_package
  end

  after do
    # Ensure that all requests have fired and are answered.  Otherwise one
    # spec can interfere with the next when a request of the former is still
    # running in the one process but the other process has already removed
    # the data in the db to prepare for the next spec.
    #
    # Taking an element, that get's activated late in the page setup.
    expect(page).to have_selector('.advanced-filters--filter label',
                                  text: I18n.t(:label_status),
                                  visible: false)
  end

  describe 'Sort link', js: true do
    before do visit_index_page end

    def click_sort_ascending_link
      expect(page).to have_selector(sort_ascending_selector)
      element = find(sort_ascending_selector)
      element.click
    end

    def click_sort_descending_link
      expect(page).to have_selector(sort_descending_selector)
      element = find(sort_descending_selector)
      element.click
    end

    shared_examples_for 'sort column' do
      it do
        expect(page).to have_selector(column_header_selector)
      end
    end

    shared_examples_for 'unsorted column' do
      it_behaves_like 'sort column'
    end

    shared_examples_for 'ascending sorted column' do
      it_behaves_like 'sort column'
    end

    shared_examples_for 'descending sorted column' do
      it_behaves_like 'sort column'
    end


    shared_examples_for 'sortable column' do
      before do expect(page).to have_selector(column_header_selector) end

      describe 'Initial sort' do
        it_behaves_like 'unsorted column'
      end

      describe 'descending' do
        before do
          find(column_header_link_selector).click
          click_sort_descending_link
          loading_indicator_saveguard
        end

        it_behaves_like 'descending sorted column'
      end

      describe 'ascending' do
        before do
          find(column_header_link_selector).click
          click_sort_ascending_link
          loading_indicator_saveguard
        end

        it_behaves_like 'ascending sorted column'
      end
    end

    describe 'id column' do
      let(:link_caption) { 'ID' }
      let(:column_header_selector) { '.work-package-table--container th:nth-of-type(1)' }
      let(:column_header_link_selector) { column_header_selector + ' a' }

      it_behaves_like 'sortable column'
    end

    describe 'subject column' do
      let(:link_caption) { 'Subject' }
      let(:column_header_selector) { '.work-package-table--container th:nth-of-type(2)' }
      let(:column_header_link_selector) { column_header_selector + ' #subject' }

      it_behaves_like 'sortable column'
    end

    describe 'type column' do
      let(:link_caption) { 'Type' }
      let(:column_header_selector) { '.work-package-table--container th:nth-of-type(3)' }
      let(:column_header_link_selector) { column_header_selector + ' a' }

      it_behaves_like 'sortable column'
    end

    describe 'status column' do
      let(:link_caption) { 'Status' }
      let(:column_header_selector) { '.work-package-table--container th:nth-of-type(4)' }
      let(:column_header_link_selector) { column_header_selector + ' a' }

      it_behaves_like 'sortable column'
    end

    describe 'assigned to column' do
      let(:link_caption) { 'Assignee' }
      let(:column_header_selector) { '.work-package-table--container th:nth-of-type(5)' }
      let(:column_header_link_selector) { column_header_selector + ' a' }

      it_behaves_like 'sortable column'
    end
  end

  describe 'hotkeys', js: true do
    let!(:another_work_package) {
      FactoryGirl.create(:work_package,
                         project: project)
    }
    before do
      visit_index_page
    end

    context 'focus' do
      let(:first_link_selector) do
        ".wp-row-#{work_package.id} td.id a"
      end
      let(:second_link_selector) do
        ".wp-row-#{another_work_package.id} td.id a"
      end

      it 'navigates with J and K' do
        expect(page).to have_selector(".wp-row-#{work_package.id}")
        expect(page).to have_selector(".wp-row-#{another_work_package.id}")

        find('body').native.send_keys('j')
        expect(page).to have_focus_on(first_link_selector)

        # Avoid sending keys on body since that resets focus
        page.driver.browser.switch_to.active_element.send_keys('j')
        expect(page).to have_focus_on(second_link_selector)

        page.driver.browser.switch_to.active_element.send_keys('k')
        expect(page).to have_focus_on(first_link_selector)
      end
    end

    context 'help' do
      it 'opens help popup with \'?\'' do
        find('body').native.send_keys('?')
        expect(page).to have_selector('.ui-dialog')
      end
    end
  end

  describe 'context menus' do
    before do
      visit_index_page
    end

    shared_examples_for 'context menu' do
      it 'resets the context menu focus properly' do
        expect(page).to have_selector(source_link)
        element = find(source_link)
        element.hover
        element.native.send_keys(keys)

        # Expect to open and focus the menu
        expect(page).to have_focus_on(target_link) if sets_focus
        element = find(target_link)

        element.native.send_keys(:escape)
        expect(page).not_to have_selector(target_link)

        # Expect reset focus on originating element
        expect(page).to have_focus_on(source_link) if sets_focus
      end
    end

    describe 'work package context menu', js: true do
      it_behaves_like 'context menu' do
        let(:target_link) { '#work-package-context-menu li.detailsViewMenuItem a' }
        let(:source_link) { '.work-package-table--container tr.issue td.id a' }
        let(:keys) { [:shift, :alt, :f10] }
        let(:sets_focus) { true }
      end

      it_behaves_like 'context menu' do
        let(:target_link) { '#work-package-context-menu li.openFullScreenView a' }
        let(:source_link) { '.work-package-table--container tr.issue td.id a' }
        let(:keys) { [:shift, :alt, :f10] }
        let(:sets_focus) { false }
      end
    end

    describe 'column header drop down menu', js: true do
      it_behaves_like 'context menu' do
        let(:source_link) { '.work-package-table--container th #subject' }
        let(:target_link) { '#column-context-menu .dropdown-menu li:first-of-type a' }
        let(:keys) { :enter }
        let(:sets_focus) { true }
      end
    end
  end

  describe 'settings button', js: true do
    before do visit_index_page end

    shared_examples_for 'menu setting item' do
      context 'closable by ESC and remembers focus on gear button' do
        before do
          find(:css, '.work-packages-settings-button').click
          anchor.click
        end
        it do
          # expect the modal to be shown
          expect(page).to have_selector('.ng-modal-window')
          find('body').native.send_keys(:escape)
          # expect it to disappear
          expect(page).not_to have_selector('.ng-modal-window')
          # expect the gear to be focused
          expect(page).to have_focus_on('#work-packages-settings-button')
        end
      end
    end

    context 'gear button' do
      context 'columns popup anchor' do
        it_behaves_like 'menu setting item' do
          let (:anchor) { find('#settingsDropdown .dropdown-menu li:nth-child(1) a') }
        end
      end

      context 'sorting popup anchor' do
        it_behaves_like 'menu setting item' do
          let (:anchor) { find('#settingsDropdown .dropdown-menu li:nth-child(2) a') }
        end
      end

      context 'grouping popup anchor' do
        let!(:query) do
          query = FactoryGirl.build(:query, user: user, project: project)
          query.show_hierarchies = false
          query.save!
          query
        end
        let(:wp_table) { Pages::WorkPackagesTable.new(project) }

        before do
          wp_table.visit_query query
        end

        it_behaves_like 'menu setting item' do
          let (:anchor) { find('#settingsDropdown .dropdown-menu li:nth-child(3) a') }
        end
      end
    end
  end
end
