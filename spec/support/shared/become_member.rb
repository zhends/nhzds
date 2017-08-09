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

module BecomeMember
  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def become_member_with_permissions(project, user, permissions = [])
      role = FactoryGirl.create :role, permissions: Array(permissions)

      add_user_to_project! user: user, project: project, role: role
    end

    def add_user_to_project!(user:, project:, role: nil, permissions: nil)
      role ||= FactoryGirl.create :existing_role, permissions: Array(permissions)
      FactoryGirl.create :member, principal: user, project: project, roles: [role]
    end
  end
end
