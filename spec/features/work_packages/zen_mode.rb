require 'spec_helper'

describe 'Zen mode', js: true do
  let(:dev_role) do
    FactoryGirl.create :role,
                       permissions: [:view_work_packages,
                                     :edit_work_packages]
  end
  let(:dev) do
    FactoryGirl.create :user,
                       firstname: 'Dev',
                       lastname: 'Guy',
                       member_in_project: project,
                       member_through_role: dev_role
  end

  let(:type) { FactoryGirl.create :type }
  let(:project) { FactoryGirl.create(:project, types: [type]) }

  let(:work_package) do
    FactoryGirl.create :work_package, project: project, type: type
  end

  let(:wp_page) { Pages::FullWorkPackage.new(work_package) }

  let(:status_from) { work_package.status }
  let(:status_intermediate) { FactoryGirl.create :status }

  before do
    login_as(dev)

    work_package

    wp_page.visit!
    wp_page.ensure_page_loaded
  end

  it 'hides menus' do
    wp_page.expect_no_zen_mode
    wp_page.page.find('#work-packages-zen-mode-toggle-button').click
    wp_page.expect_zen_mode
    wp_page.page.find('.work-packages-list-view-button').click
    wp_page.expect_zen_mode
    wp_page.page.find('#work-packages-zen-mode-toggle-button').click
    wp_page.expect_no_zen_mode
  end
end
