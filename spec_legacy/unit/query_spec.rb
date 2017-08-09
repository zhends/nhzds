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
require_relative '../legacy_spec_helper'

describe Query, type: :model do
  fixtures :all

  it 'should system shared versions should be available in global queries' do
    Version.find(2).update_attribute :sharing, 'system'
    query = Query.new(project: nil, name: '_')
    assert query.filter_for('fixed_version_id')[:allowed_values].detect { |v| v.last == '2' }
  end

  it 'should project filter in global queries' do
    # User.current should be anonymous here
    query = Query.new(project: nil, name: '_')
    project_filter = query.filter_for('project_id')
    refute_nil project_filter
    project_ids = project_filter[:allowed_values].map { |p| p[1] }
    assert project_ids.include?('1')  # public project
    assert !project_ids.include?('2') # private project anonymous user cannot see
  end

  def find_issues_with_query(query)
    WorkPackage.includes(:assigned_to, :status, :type, :project, :priority)
               .where(query.statement)
               .references(:projects)
  end

  def assert_find_issues_with_query_is_successful(query)
    expect {
      find_issues_with_query(query)
    }.not_to raise_error
  end

  def assert_query_statement_includes(query, condition)
    assert query.statement.include?(condition),
           "Query statement condition not found in: #{query.statement}"
  end

  it 'should query should allow shared versions for a project query' do
    subproject_version = Version.find(4)
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('fixed_version_id', '=', [subproject_version.id.to_s])

    assert query.statement.include?("#{WorkPackage.table_name}.fixed_version_id IN ('4')")
  end

  it 'should query with multiple custom fields' do
    query = Query.find(1)
    assert query.valid?
    assert query.statement.include?("#{CustomValue.table_name}.value IN ('1')")
    issues = find_issues_with_query(query)
    assert_equal 1, issues.length
    assert_equal WorkPackage.find(3), issues.first
  end

  it 'should operator none' do
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('fixed_version_id', '!*', [''])
    query.add_filter('cf_1', '!*', [''])
    assert query.statement.include?("#{WorkPackage.table_name}.fixed_version_id IS NULL")
    assert query.statement.include?("#{CustomValue.table_name}.value IS NULL OR #{CustomValue.table_name}.value = ''")
    find_issues_with_query(query)
  end

  it 'should operator none for integer' do
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('estimated_hours', '!*', [''])
    issues = find_issues_with_query(query)
    assert !issues.empty?
    assert issues.all? { |i| !i.estimated_hours }
  end

  it 'should operator all' do
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('fixed_version_id', '*', [''])
    query.add_filter('cf_1', '*', [''])
    assert query.statement.include?("#{WorkPackage.table_name}.fixed_version_id IS NOT NULL")
    assert query.statement.include?("#{CustomValue.table_name}.value IS NOT NULL AND #{CustomValue.table_name}.value <> ''")
    find_issues_with_query(query)
  end

  it 'should operator greater than' do
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('done_ratio', '>=', ['40'])
    assert query.statement.include?("#{WorkPackage.table_name}.done_ratio >= 40")
    find_issues_with_query(query)
  end

  it 'should operator in more than' do
    WorkPackage.find(7).update_attribute(:due_date, (Date.today + 15))
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('due_date', '>t+', ['15'])
    issues = find_issues_with_query(query)
    assert !issues.empty?
    issues.each { |issue| assert(issue.due_date >= (Date.today + 15)) }
  end

  it 'should operator in less than' do
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('due_date', '<t+', ['15'])
    issues = find_issues_with_query(query)
    assert !issues.empty?
    issues.each { |issue| assert(issue.due_date >= Date.today && issue.due_date <= (Date.today + 15)) }
  end

  it 'should operator less than ago' do
    WorkPackage.find(7).update_attribute(:due_date, (Date.today - 3))
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('due_date', '>t-', ['3'])
    issues = find_issues_with_query(query)
    assert !issues.empty?
    issues.each { |issue| assert(issue.due_date >= (Date.today - 3) && issue.due_date <= Date.today) }
  end

  it 'should operator more than ago' do
    WorkPackage.find(7).update_attribute(:due_date, (Date.today - 10))
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('due_date', '<t-', ['10'])
    assert query.statement.include?("#{WorkPackage.table_name}.due_date <=")
    issues = find_issues_with_query(query)
    assert !issues.empty?
    issues.each { |issue| assert(issue.due_date <= (Date.today - 10)) }
  end

  it 'should operator in' do
    WorkPackage.find(7).update_attribute(:due_date, (Date.today + 2))
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('due_date', 't+', ['2'])
    issues = find_issues_with_query(query)
    assert !issues.empty?
    issues.each { |issue| assert_equal((Date.today + 2), issue.due_date) }
  end

  it 'should operator ago' do
    WorkPackage.find(7).update_attribute(:due_date, (Date.today - 3))
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('due_date', 't-', ['3'])
    issues = find_issues_with_query(query)
    assert !issues.empty?
    issues.each { |issue| assert_equal((Date.today - 3), issue.due_date) }
  end

  it 'should operator today' do
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('due_date', 't', [''])
    issues = find_issues_with_query(query)
    assert !issues.empty?
    issues.each { |issue| assert_equal Date.today, issue.due_date }
  end

  it 'should operator this week on date' do
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('due_date', 'w', [''])
    find_issues_with_query(query)
  end

  it 'should operator this week on datetime' do
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('created_on', 'w', [''])
    find_issues_with_query(query)
  end

  it 'should operator contains' do
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('subject', '~', ['uNable'])
    assert query.statement.include?("LOWER(#{WorkPackage.table_name}.subject) LIKE '%unable%'")
    result = find_issues_with_query(query)
    assert result.empty?
    result.each { |issue| assert issue.subject.downcase.include?('unable') }
  end

  it 'should operator does not contains' do
    query = Query.new(project: Project.find(1), name: '_')
    query.add_filter('subject', '!~', ['uNable'])
    assert query.statement.include?("LOWER(#{WorkPackage.table_name}.subject) NOT LIKE '%unable%'")
    find_issues_with_query(query)
  end

  it 'should filter assigned to me' do
    user = User.find(2)
    group = Group.find(10)
    project = Project.find(1)
    User.current = user
    i1 = FactoryGirl.create(:work_package, project: project, type: project.types.first, assigned_to: user)
    i2 = FactoryGirl.create(:work_package, project: project, type: project.types.first, assigned_to: group)
    i3 = FactoryGirl.create(:work_package, project: project, type: project.types.first, assigned_to: Group.find(11))
    group.users << user

    query = Query.new(name: '_', filters: [{ assigned_to_id: { operator: '=', values: ['me'] } }])
    result = query.results.work_packages
    assert_equal WorkPackage.visible.where(assigned_to_id: ([2] + user.reload.group_ids)).sort_by(&:id), result.sort_by(&:id)

    assert result.include?(i1)
    assert result.include?(i2)
    assert !result.include?(i3)

    User.current = nil
  end

  it 'should filter watched issues' do
    User.current = User.find(1)
    query = Query.new(name: '_', filters: [{ watcher_id: { operator: '=', values: ['me'] } }])
    result = find_issues_with_query(query)
    refute_nil result
    assert !result.empty?
    assert_equal WorkPackage.visible.watched_by(User.current).sort_by(&:id), result.sort_by(&:id)
    User.current = nil
  end

  it 'should filter unwatched issues' do
    User.current = User.find(1)
    query = Query.new(name: '_', filters: [{ watcher_id: { operator: '!', values: ['me'] } }])
    result = find_issues_with_query(query)
    refute_nil result
    assert !result.empty?
    expect((WorkPackage.visible - WorkPackage.watched_by(User.current)).size).to eql result.size
    User.current = nil
  end

  it 'should default columns' do
    q = Query.new name: '_'
    assert !q.columns.empty?
  end

  it 'should set column names' do
    q = Query.new name: '_'
    q.column_names = ['type', :subject, '', 'unknonw_column']
    assert_equal [:type, :subject], q.columns.map(&:name)
    c = q.columns.first
    assert q.has_column?(c)
  end

  it 'should groupable columns should include custom fields' do
    q = Query.new name: '_'
    assert q.groupable_columns.detect { |c| c.is_a? Queries::WorkPackages::Columns::CustomFieldColumn }
  end

  it 'should grouped with valid column' do
    q = Query.new(group_by: 'status', name: '_')
    assert q.grouped?
    refute_nil q.group_by_column
    assert_equal :status, q.group_by_column.name
    refute_nil q.group_by_statement
    assert_equal 'status', q.group_by_statement
  end

  it 'should grouped with invalid column' do
    q = Query.new(group_by: 'foo', name: '_')
    assert !q.grouped?
    assert_nil q.group_by_column
    assert_nil q.group_by_statement
  end

  it 'should default sort' do
    q = Query.new name: '_'
    assert_equal [], q.sort_criteria
  end

  it 'should set sort criteria with hash' do
    q = Query.new name: '_'
    q.sort_criteria = { '0' => ['priority', 'desc'], '2' => ['type'] }
    assert_equal [['priority', 'desc'], ['type', 'asc']], q.sort_criteria
  end

  it 'should set sort criteria with array' do
    q = Query.new name: '_'
    q.sort_criteria = [['priority', 'desc'], 'type']
    assert_equal [['priority', 'desc'], ['type', 'asc']], q.sort_criteria
  end

  it 'should create query with sort' do
    q = Query.new name: 'Sorted'
    q.sort_criteria = [['priority', 'desc'], 'type']
    assert q.save
    q.reload
    assert_equal [['priority', 'desc'], ['type', 'asc']], q.sort_criteria
  end

  it 'should sort by string custom field asc' do
    q = Query.new name: '_'
    c = q.available_columns.find { |col| col.is_a?(Queries::WorkPackages::Columns::CustomFieldColumn) && col.custom_field.field_format == 'string' }
    assert c
    assert c.sortable
    issues = WorkPackage.includes(:assigned_to, :status, :type, :project, :priority)
                        .where(q.statement)
                        .order(Array(c.sortable).map { |s| "#{s} ASC" }.join(', '))
                        .references(:projects)
    values = issues.map { |i| i.custom_value_for(c.custom_field).to_s }
    assert !values.empty?
    assert_equal values.sort, values
  end

  it 'should sort by string custom field desc' do
    q = Query.new name: '_'
    c = q.available_columns.find { |col| col.is_a?(Queries::WorkPackages::Columns::CustomFieldColumn) && col.custom_field.field_format == 'string' }
    assert c
    assert c.sortable
    issues = WorkPackage.includes(:assigned_to, :status, :type, :project, :priority)
             .where(q.statement)
             .order(Array(c.sortable).map { |s| "#{s} DESC" }.join(', '))
             .references(:projects)
    values = issues.map { |i| i.custom_value_for(c.custom_field).to_s }
    assert !values.empty?
    assert_equal values.sort.reverse, values
  end

  it 'should sort by float custom field asc' do
    q = Query.new name: '_'
    c = q.available_columns.find { |col| col.is_a?(Queries::WorkPackages::Columns::CustomFieldColumn) && col.custom_field.field_format == 'float' }
    assert c
    assert c.sortable
    issues = WorkPackage
             .includes(:assigned_to, :status, :type, :project, :priority)
             .where(q.statement)
             .order(Array(c.sortable).map { |s| "#{s} ASC" }.join(', '))
             .references(:projects)
    values = issues.map { |i| begin; Kernel.Float(i.custom_value_for(c.custom_field).to_s); rescue; nil; end }.compact
    assert !values.empty?
    assert_equal values.sort, values
  end

  it 'should invalid query should raise query statement invalid error' do
    q = Query.new name: '_'
    assert_raises ActiveRecord::StatementInvalid do
      q.results(conditions: 'foo = 1').work_packages.to_a
    end
  end

  it 'should issue count by association group' do
    q = Query.new(name: '_',
                  group_by: 'assigned_to',
                  show_hierarchies: false)

    count_by_group = q.results.work_package_count_by_group
    assert_kind_of Hash, count_by_group
    assert_equal %w(NilClass User), count_by_group.keys.map { |k| k.class.name }.uniq.sort
    assert_equal %w(Integer), count_by_group.values.map { |k| k.class.name }.uniq
    assert count_by_group.has_key?(User.find(3))
  end

  it 'should issue count by list custom field group' do
    q = Query.new(name: '_',
                  group_by: 'cf_1',
                  show_hierarchies: false)

    count_by_group = q.results.work_package_count_by_group
    assert_kind_of Hash, count_by_group
    expect(count_by_group.keys.map { |k| k.class.name }.uniq)
      .to match_array(%w(CustomOption NilClass))
    assert_equal %w(Integer), count_by_group.values.map { |k| k.class.name }.uniq
    expect(count_by_group.any? { |k, v| k.is_a?(CustomOption) && k.id == 1 && v == 1 })
      .to be_truthy
  end

  it 'should issue count by date custom field group' do
    q = Query.new(name: '_',
                  group_by: 'cf_8',
                  show_hierarchies: false)

    count_by_group = q.results.work_package_count_by_group
    assert_kind_of Hash, count_by_group
    assert_equal %w(Date NilClass), count_by_group.keys.map { |k| k.class.name }.uniq.sort
    assert_equal %w(Integer), count_by_group.values.map { |k| k.class.name }.uniq
  end

  context '#filter_for' do
    before do
      @query = Query.new(name: '_')
    end

    it 'should include users of visible projects in cross-project view' do
      users = @query.filter_for('assigned_to_id')
      refute_nil users
      assert users[:allowed_values].map { |u| u[1] }.include?('3')
    end

    it 'should include visible projects in cross-project view' do
      projects = @query.filter_for('project_id')
      refute_nil projects
      assert projects[:allowed_values].map { |u| u[1] }.include?('1')
    end

    context "'member_of_group' filter" do
      it 'should be present' do
        assert @query.filter_for('member_of_group')
      end

      it 'should be an optional list' do
        assert_equal :list_optional, @query.filter_for('member_of_group')[:type]
      end

      it 'should have a list of the groups as values' do
        Group.destroy_all # No fixtures
        group1 = FactoryGirl.create(:group).reload
        group2 = FactoryGirl.create(:group).reload

        expected_group_list = [
          [group1.name, group1.id.to_s],
          [group2.name, group2.id.to_s]
        ]
        assert_equal expected_group_list.sort, @query.filter_for('member_of_group')[:allowed_values].sort
      end
    end

    context "'assigned_to_role' filter" do
      it 'should be present' do
        assert @query.filter_for('assigned_to_role')
      end

      it 'should be an optional list' do
        assert_equal :list_optional, @query.filter_for('assigned_to_role')[:type]
      end

      it 'should have a list of the Roles as values' do
        assert @query.filter_for('assigned_to_role')[:allowed_values].include?(['Manager', '1'])
        assert @query.filter_for('assigned_to_role')[:allowed_values].include?(['Developer', '2'])
        assert @query.filter_for('assigned_to_role')[:allowed_values].include?(['Reporter', '3'])
      end

      it 'should not include the built in Roles as allowed_values' do
        assert !@query.filter_for('assigned_to_role')[:allowed_values].include?(['Non member', '4'])
        assert !@query.filter_for('assigned_to_role')[:allowed_values].include?(['Anonymous', '5'])
      end
    end

    context "'watcher_id' filter" do
      context 'globally' do
        context 'for a logged in user' do
          before do
            User.current = User.find 1
          end

          after do
            User.current = nil
          end

          it 'should be present' do
            assert @query.filter_for('watcher_id')
          end

          it 'should be a list' do
            assert_equal :list, @query.filter_for('watcher_id')[:type]
          end

          it 'should have a list of active users as allowed_values' do
            assert @query.filter_for('watcher_id')[:allowed_values].include?(['me', 'me'])
            assert @query.filter_for('watcher_id')[:allowed_values].include?(['John Smith', '2'])
            assert @query.filter_for('watcher_id')[:allowed_values].include?(['Dave Lopper', '3'])
            assert @query.filter_for('watcher_id')[:allowed_values].include?(['redMine Admin', '1'])
            assert @query.filter_for('watcher_id')[:allowed_values].include?(['User Misc', '8'])
          end

          it 'should not include active users not member of any project' do
            assert !@query.filter_for('watcher_id')[:allowed_values].include?(['Robert Hill', '4'])
          end

          it 'should not include locked users as values' do
            assert !@query.filter_for('watcher_id')[:allowed_values].include?(['Dave2 Lopper2', '5'])
          end

          it 'should not include the anonymous user as values' do
            assert !@query.filter_for('watcher_id')[:allowed_values].include?(['Anonymous', '6'])
          end
        end
      end

      context 'in a project' do
        before do
          @query.project = Project.find(1)
        end

        context 'for a logged in user' do
          before do
            allow(User).to receive(:current).and_return(User.find(1))
          end

          it 'should be present' do
            assert @query.filter_for('watcher_id')
          end

          it 'should be a list' do
            assert_equal :list, @query.filter_for('watcher_id')[:type]
          end

          it 'should have a list of the project members as allowed_values' do
            assert @query.filter_for('watcher_id')[:allowed_values].include?(['me', 'me'])
            assert @query.filter_for('watcher_id')[:allowed_values].include?(['John Smith', '2'])
            assert @query.filter_for('watcher_id')[:allowed_values].include?(['Dave Lopper', '3'])
          end

          it 'should not include non-project members as allowed_values' do
            assert !@query.filter_for('watcher_id')[:allowed_values].include?(['redMine Admin', '1'])
          end

          it 'should not include locked project members as allowed_values' do
            assert !@query.filter_for('watcher_id')[:allowed_values].include?(['Dave2 Lopper2', '5'])
          end

          it 'should not include the anonymous user as allowed_values' do
            assert !@query.filter_for('watcher_id')[:allowed_values].include?(['Anonymous', '6'])
          end
        end
      end
    end
  end

  context '#statement' do
    context "with 'member_of_group' filter" do
      before do
        Group.destroy_all # No fixtures
        @user_in_group = FactoryGirl.create(:user)
        @second_user_in_group = FactoryGirl.create(:user)
        @user_in_group2 = FactoryGirl.create(:user)
        @user_not_in_group = FactoryGirl.create(:user)

        @group = FactoryGirl.create(:group).reload
        @group.users << @user_in_group
        @group.users << @second_user_in_group

        @group2 = FactoryGirl.create(:group).reload
        @group2.users << @user_in_group2

        @empty_group = FactoryGirl.create(:group).reload
      end

      it 'should search assigned to for users in the group' do
        @query = Query.new(name: '_')
        @query.add_filter('member_of_group', '=', [@group.id.to_s])

        assert_query_statement_includes @query, "#{WorkPackage.table_name}.assigned_to_id IN ('#{@user_in_group.id}','#{@second_user_in_group.id}')"
        assert_find_issues_with_query_is_successful @query
      end

      it 'should search not assigned to any group member (none)' do
        @query = Query.new(name: '_')
        @query.add_filter('member_of_group', '!*', [''])

        # Users not in a group
        assert_query_statement_includes @query, "#{WorkPackage.table_name}.assigned_to_id IS NULL OR #{WorkPackage.table_name}.assigned_to_id NOT IN ('#{@user_in_group.id}','#{@second_user_in_group.id}','#{@user_in_group2.id}')"
        assert_find_issues_with_query_is_successful @query
      end

      it 'should search assigned to any group member (all)' do
        @query = Query.new(name: '_')
        @query.add_filter('member_of_group', '*', [''])

        # Only users in a group
        assert_query_statement_includes @query, "#{WorkPackage.table_name}.assigned_to_id IN ('#{@user_in_group.id}','#{@second_user_in_group.id}','#{@user_in_group2.id}')"
        assert_find_issues_with_query_is_successful @query
      end

      it 'should return no results on empty set' do
        @query = Query.new(name: '_')
        @query.add_filter('member_of_group', '=', [@empty_group.id.to_s])

        assert_query_statement_includes @query, '(0=1)'
        assert find_issues_with_query(@query).empty?
      end

      it 'should return results on disallowed empty set' do
        @query = Query.new(name: '_')
        @query.add_filter('member_of_group', '!', [@empty_group.id.to_s])

        assert_query_statement_includes @query, '(1=1)'
        assert_find_issues_with_query_is_successful @query
      end
    end

    context "with 'assigned_to_role' filter" do
      before do
        # No fixtures
        MemberRole.delete_all
        Member.delete_all
        Role.delete_all

        @manager_role = FactoryGirl.create(:role, name: 'Manager')
        @developer_role = FactoryGirl.create(:role, name: 'Developer')
        @empty_role = FactoryGirl.create(:role, name: 'Empty')

        @project = FactoryGirl.create(:project)
        @manager = FactoryGirl.create(:user)
        @developer = FactoryGirl.create(:user)
        @boss = FactoryGirl.create(:user)
        FactoryGirl.create(:member, user: @manager, project: @project, role_ids: [@manager_role.id])
        FactoryGirl.create(:member, user: @developer, project: @project, role_ids: [@developer_role.id])
        FactoryGirl.create(:member, user: @boss, project: @project, role_ids: [@manager_role, @developer_role].map(&:id))
      end

      it 'should search assigned to for users with the Role' do
        @query = Query.new(name: '_')
        @query.add_filter('assigned_to_role', '=', [@manager_role.id.to_s])

        assert_query_statement_includes @query, "#{WorkPackage.table_name}.assigned_to_id IN ('#{@manager.id}','#{@boss.id}')"
        assert_find_issues_with_query_is_successful @query
      end

      it 'should search assigned to for users not assigned to any Role (none)' do
        @query = Query.new(name: '_')
        @query.add_filter('assigned_to_role', '!*', [''])

        assert_query_statement_includes @query, "#{WorkPackage.table_name}.assigned_to_id IS NULL OR #{WorkPackage.table_name}.assigned_to_id NOT IN ('#{@manager.id}','#{@developer.id}','#{@boss.id}')"
        assert_find_issues_with_query_is_successful @query
      end

      it 'should search assigned to for users assigned to any Role (all)' do
        @query = Query.new(name: '_')
        @query.add_filter('assigned_to_role', '*', [''])

        assert_query_statement_includes @query, "#{WorkPackage.table_name}.assigned_to_id IN ('#{@manager.id}','#{@developer.id}','#{@boss.id}')"
        assert_find_issues_with_query_is_successful @query
      end

      it 'should return no results on empty set' do
        @query = Query.new(name: '_')
        @query.add_filter('assigned_to_role', '=', [@empty_role.id.to_s])

        assert_query_statement_includes @query, '(0=1)'
        assert find_issues_with_query(@query).empty?
      end

      it 'should return results on disallowed empty set' do
        @query = Query.new(name: '_')
        @query.add_filter('assigned_to_role', '!', [@empty_role.id.to_s])

        assert_query_statement_includes @query, '(1=1)'
        assert_find_issues_with_query_is_successful @query
      end
    end
  end
end
