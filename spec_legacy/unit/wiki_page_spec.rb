#-- encoding: UTF-8
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
require 'legacy_spec_helper'

describe WikiPage, type: :model do
  fixtures :all

  before do
    @wiki = Wiki.find(1)
    @page = @wiki.pages.first
  end

  it 'should create' do
    page = WikiPage.new(wiki: @wiki)
    assert !page.save
    assert_equal 1, page.errors.count

    page.title = 'Page'
    assert page.save
    page.reload
    assert !page.protected?

    @wiki.reload
    assert @wiki.pages.include?(page)
  end

  it 'should sidebar should be protected by default' do
    page = @wiki.find_or_new_page('sidebar')
    assert page.new_record?
    assert page.protected?
  end

  it 'should find or new page' do
    page = @wiki.find_or_new_page('CookBook documentation')
    assert_kind_of WikiPage, page
    assert !page.new_record?

    page = @wiki.find_or_new_page('Non existing page')
    assert_kind_of WikiPage, page
    assert page.new_record?
  end

  it 'should parent title' do
    page = WikiPage.find_by(title: 'Another page')
    assert_nil page.parent_title

    page = WikiPage.find_by(title: 'Page with an inline image')
    assert_equal 'CookBook documentation', page.parent_title
  end

  it 'should assign parent' do
    page = WikiPage.find_by(title: 'Another page')
    page.parent_title = 'CookBook documentation'
    assert page.save
    page.reload
    assert_equal WikiPage.find_by(title: 'CookBook documentation'), page.parent
  end

  it 'should unassign parent' do
    page = WikiPage.find_by(title: 'Page with an inline image')
    page.parent_title = ''
    assert page.save
    page.reload
    assert_nil page.parent
  end

  it 'should parent validation' do
    page = WikiPage.find_by(title: 'CookBook documentation')

    # A child page
    page.parent_title = 'Page with an inline image'
    assert !page.save
    assert_includes page.errors[:parent_title], I18n.translate('activerecord.errors.messages.circular_dependency')
    # The page itself
    page.parent_title = 'CookBook documentation'
    assert !page.save
    assert_includes page.errors[:parent_title], I18n.translate('activerecord.errors.messages.circular_dependency')

    page.parent_title = 'Another page'
    assert page.save
  end

  it 'should destroy' do
    page = WikiPage.find(1)
    content_ids = WikiContent.where(page_id: 1).map(&:id)
    page.destroy
    assert_nil WikiPage.find_by(id: 1)
    # make sure that page content and its history are deleted
    assert WikiContent.where(page_id: 1).empty?
    content_ids.each do |wiki_content_id|
      assert Journal.where(journable_type: 'WikiContent',
                           journable_id: wiki_content_id)
    end
  end

  it 'should destroy should not nullify children' do
    page = WikiPage.find(2)
    child_ids = page.child_ids
    assert child_ids.any?
    page.destroy
    assert_nil WikiPage.find_by(id: 2)

    children = WikiPage.where(id: child_ids)
    assert_equal child_ids.size, children.size
    children.each do |child|
      assert_nil child.parent_id
    end
  end

  it 'should updated on eager load' do
    page = WikiPage.with_updated_on.first
    assert page.is_a?(WikiPage)
    refute_nil page.read_attribute(:updated_on)
    assert_equal page.content.updated_on, page.updated_on
  end
end
