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

describe Changeset, type: :model do
  fixtures :all

  context 'with notified events', with_settings: { notified_events: %w(work_package_updated) } do
    it 'should ref keywords any' do
      WorkPackage.all.each(&:recreate_initial_journal!)

      Setting.commit_fix_status_id = Status.where(['is_closed = ?', true]).first.id
      Setting.commit_fix_done_ratio = '90'
      Setting.commit_ref_keywords = '*'
      Setting.commit_fix_keywords = 'fixes , closes'

      c = Changeset.new(repository: Project.find(1).repository,
                        committed_on: Time.now,
                        comments: 'New commit (#2). Fixes #1')
      c.scan_comment_for_work_package_ids

      assert_equal [1, 2], c.work_package_ids.sort
      fixed = WorkPackage.find(1)
      assert fixed.closed?
      assert_equal 90, fixed.done_ratio
      assert_equal 2, ActionMailer::Base.deliveries.size
    end

    it 'should ref keywords' do
      Setting.commit_ref_keywords = 'refs'
      Setting.commit_fix_keywords = ''

      c = Changeset.new(repository: Project.find(1).repository,
                        committed_on: Time.now,
                        comments: 'Ignores #2. Refs #1')
      c.scan_comment_for_work_package_ids

      assert_equal [1], c.work_package_ids.sort
    end

    it 'should ref keywords any only' do
      Setting.commit_ref_keywords = '*'
      Setting.commit_fix_keywords = ''

      c = Changeset.new(repository: Project.find(1).repository,
                        committed_on: Time.now,
                        comments: 'Ignores #2. Refs #1')
      c.scan_comment_for_work_package_ids

      assert_equal [1, 2], c.work_package_ids.sort
    end

    it 'should ref keywords any with timelog' do
      Setting.commit_ref_keywords = '*'
      Setting.commit_logtime_enabled = '1'

      {
        '2' => 2.0,
        '2h' => 2.0,
        '2hours' => 2.0,
        '15m' => 0.25,
        '15min' => 0.25,
        '3h15' => 3.25,
        '3h15m' => 3.25,
        '3h15min' => 3.25,
        '3:15' => 3.25,
        '3.25' => 3.25,
        '3.25h' => 3.25,
        '3,25' => 3.25,
        '3,25h' => 3.25
      }.each do |syntax, expected_hours|
        c = Changeset.new(repository: Project.find(1).repository,
                          committed_on: 24.hours.ago,
                          comments: "Worked on this work_package #1 @#{syntax}",
                          revision: '520',
                          user: User.find(2))
        assert_difference 'TimeEntry.count' do
          c.scan_comment_for_work_package_ids
        end
        assert_equal [1], c.work_package_ids.sort

        time = TimeEntry.order('id DESC').first
        assert_equal 1, time.work_package_id
        assert_equal 1, time.project_id
        assert_equal 2, time.user_id
        assert_equal expected_hours,
                     time.hours,
                     "@#{syntax} should be logged as #{expected_hours} hours but was #{time.hours}"
        assert_equal Date.yesterday, time.spent_on
        assert time.activity.is_default?
        assert time.comments.include?('r520'),
               "r520 was expected in time_entry comments: #{time.comments}"
      end
    end

    it 'should ref keywords closing with timelog' do
      Setting.commit_fix_status_id = Status.where(['is_closed = ?', true]).first.id
      Setting.commit_ref_keywords = '*'
      Setting.commit_fix_keywords = 'fixes , closes'
      Setting.commit_logtime_enabled = '1'

      c = Changeset.new(repository: Project.find(1).repository,
                        committed_on: Time.now,
                        comments: 'This is a comment. Fixes #1 @4.5, #2 @1',
                        user: User.find(2))
      assert_difference 'TimeEntry.count', 2 do
        c.scan_comment_for_work_package_ids
      end

      assert_equal [1, 2], c.work_package_ids.sort
      assert WorkPackage.find(1).closed?
      assert WorkPackage.find(2).closed?

      times = TimeEntry.order('id desc').limit(2)
      assert_equal [1, 2], times.map(&:work_package_id).sort
    end

    it 'should ref keywords any line start' do
      Setting.commit_ref_keywords = '*'

      c = Changeset.new(repository: Project.find(1).repository,
                        committed_on: Time.now,
                        comments: '#1 is the reason of this commit')
      c.scan_comment_for_work_package_ids

      assert_equal [1], c.work_package_ids.sort
    end

    it 'should ref keywords allow brackets around a work package number' do
      Setting.commit_ref_keywords = '*'

      c = Changeset.new(repository: Project.find(1).repository,
                        committed_on: Time.now,
                        comments: '[#1] Worked on this work_package')
      c.scan_comment_for_work_package_ids

      assert_equal [1], c.work_package_ids.sort
    end

    it 'should ref keywords allow brackets around multiple work package numbers' do
      Setting.commit_ref_keywords = '*'

      c = Changeset.new(repository: Project.find(1).repository,
                        committed_on: Time.now,
                        comments: '[#1 #2, #3] Worked on these')
      c.scan_comment_for_work_package_ids

      assert_equal [1, 2, 3], c.work_package_ids.sort
    end

    it 'should commit referencing a subproject work package' do
      c = Changeset.new(repository: Project.find(1).repository,
                        committed_on: Time.now,
                        comments: 'refs #5, a subproject work_package')
      c.scan_comment_for_work_package_ids

      assert_equal [5], c.work_package_ids.sort
      assert c.work_packages.first.project != c.project
    end

    it 'should commit referencing a parent project work package' do
      # repository of child project
      r = Repository::Subversion.create!(
        project: Project.find(3),
        scm_type: 'existing',
        url:      'svn://localhost/test')

      c = Changeset.new(repository: r,
                        committed_on: Time.now,
                        comments: 'refs #2, an work_package of a parent project')
      c.scan_comment_for_work_package_ids

      assert_equal [2], c.work_package_ids.sort
      assert c.work_packages.first.project != c.project
    end

    it 'should text tag revision' do
      c = Changeset.new(revision: '520')
      assert_equal 'r520', c.text_tag
    end

    it 'should text tag hash' do
      c = Changeset.new(
        scmid:    '7234cb2750b63f47bff735edc50a1c0a433c2518',
        revision: '7234cb2750b63f47bff735edc50a1c0a433c2518')
      assert_equal 'commit:7234cb2750b63f47bff735edc50a1c0a433c2518', c.text_tag
    end

    it 'should text tag hash all number' do
      c = Changeset.new(scmid: '0123456789', revision: '0123456789')
      assert_equal 'commit:0123456789', c.text_tag
    end

    it 'should previous' do
      changeset = Changeset.find_by(revision: '3')
      assert_equal Changeset.find_by(revision: '2'), changeset.previous
    end

    it 'should previous nil' do
      changeset = Changeset.find_by(revision: '1')
      assert_nil changeset.previous
    end

    it 'should next' do
      changeset = Changeset.find_by(revision: '2')
      assert_equal Changeset.find_by(revision: '3'), changeset.next
    end

    it 'should next nil' do
      changeset = Changeset.find_by(revision: '10')
      assert_nil changeset.next
    end
  end

  context 'enabled scm', with_settings: { enabled_scm: ['subversion'] } do
    it 'should comments empty' do
      r = FactoryGirl.create(:repository_subversion)

      assert r
      c = Changeset.new(repository: r,
                        committed_on: Time.now,
                        revision: '123',
                        scmid: '12345',
                        comments: '')
      assert(c.save)
      assert_equal '', c.comments
      if c.comments.respond_to?(:force_encoding)
        assert_equal 'UTF-8', c.comments.encoding.to_s
      end
    end

    it 'should comments nil' do
      r = FactoryGirl.create(:repository_subversion)
      assert r

      c = Changeset.new(repository: r,
                        committed_on: Time.now,
                        revision: '123',
                        scmid: '12345',
                        comments: nil)
      assert(c.save)
      assert_equal '', c.comments
      if c.comments.respond_to?(:force_encoding)
        assert_equal 'UTF-8', c.comments.encoding.to_s
      end
    end

    it 'should identifier' do
      c = Changeset.find_by(revision: '1')
      assert_equal c.revision, c.identifier
    end
  end
end
