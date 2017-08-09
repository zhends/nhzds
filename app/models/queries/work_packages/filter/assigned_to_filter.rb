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

class Queries::WorkPackages::Filter::AssignedToFilter <
  Queries::WorkPackages::Filter::PrincipalBaseFilter
  def allowed_values
    @allowed_values ||= begin
      values = principal_loader.user_values

      if Setting.work_package_group_assignment?
        values += principal_loader.group_values
      end

      me_value + values.sort
    end
  end

  def type
    :list_optional
  end

  def order
    4
  end

  def human_name
    WorkPackage.human_attribute_name('assigned_to')
  end

  def self.key
    :assigned_to_id
  end

  private

  def values_replaced
    vals = super
    vals += group_members_added(vals)
    vals + user_groups_added(vals)
  end

  def group_members_added(vals)
    User
      .joins(:groups)
      .where(groups_users: { id: vals })
      .pluck(:id)
      .map(&:to_s)
  end

  def user_groups_added(vals)
    Group
      .joins(:users)
      .where(users_users: { id: vals })
      .pluck(:id)
      .map(&:to_s)
  end
end
