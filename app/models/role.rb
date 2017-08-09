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

class Role < ActiveRecord::Base
  extend Pagination::Model

  # Built-in roles
  BUILTIN_NON_MEMBER = 1
  BUILTIN_ANONYMOUS  = 2

  scope :givable, -> {
    where('builtin = 0')
      .order('position')
  }
  scope :builtin, -> (*args) {
    compare = 'not' if args.first == true
    where("#{compare} builtin = 0")
  }

  before_destroy :check_deletable
  has_many :workflows, dependent: :delete_all do
    def copy_from_role(source_role)
      Workflow.copy(nil, source_role, nil, proxy_association.owner)
    end
  end

  has_many :member_roles, dependent: :destroy
  has_many :members, through: :member_roles
  has_many :role_permissions

  default_scope -> {
    includes(:role_permissions)
  }

  acts_as_list

  # serialize :permissions, Array

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, maximum: 30

  def permissions
    # prefer map over pluck as we will probably always load
    # the permissions anyway
    role_permissions.map(&:permission).map(&:to_sym)
  end

  def permissions=(perms)
    not_included_yet = (perms.map(&:to_sym) - permissions).reject(&:blank?)
    included_until_now = permissions - perms.map(&:to_sym)

    remove_permission!(*included_until_now)

    add_permission!(*not_included_yet)
  end

  def add_permission!(*perms)
    perms.each do |perm|
      add_permission(perm)
    end
  end

  def remove_permission!(*perms)
    return unless permissions.is_a?(Array)

    perms = perms.map(&:to_s)

    self.role_permissions = role_permissions.reject { |rp|
      perms.include?(rp.permission)
    }
  end

  # Returns true if the role has the given permission
  def has_permission?(perm)
    !permissions.nil? && permissions.include?(perm.to_sym)
  end

  def <=>(role)
    role ? position <=> role.position : -1
  end

  def to_s
    name
  end

  # Return true if the role is a builtin role
  def builtin?
    builtin != 0
  end

  # Return true if the role is a project member role
  def member?
    !self.builtin?
  end

  # Return true if role is allowed to do the specified action
  # action can be:
  # * a parameter-like Hash (eg. controller: '/projects', action: 'edit')
  # * a permission Symbol (eg. :edit_project)
  def allowed_to?(action)
    if action.is_a? Hash
      allowed_actions.include? "#{action[:controller]}/#{action[:action]}"
    else
      allowed_permissions.include? action
    end
  end

  # Return all the permissions that can be given to the role
  def setable_permissions
    setable_permissions = Redmine::AccessControl.permissions - Redmine::AccessControl.public_permissions
    setable_permissions -= Redmine::AccessControl.members_only_permissions if builtin == BUILTIN_NON_MEMBER
    setable_permissions -= Redmine::AccessControl.loggedin_only_permissions if builtin == BUILTIN_ANONYMOUS
    setable_permissions
  end

  # Find all the roles that can be given to a project member
  def self.find_all_givable
    where(builtin: 0).order('position')
  end

  # Return the builtin 'non member' role.  If the role doesn't exist,
  # it will be created on the fly.
  def self.non_member
    non_member_role = where(builtin: BUILTIN_NON_MEMBER).first
    if non_member_role.nil?
      non_member_role = create(name: 'Non member', position: 0) do |role|
        role.builtin = BUILTIN_NON_MEMBER
      end
      raise 'Unable to create the non-member role.' if non_member_role.new_record?
    end
    non_member_role
  end

  # Return the builtin 'anonymous' role.  If the role doesn't exist,
  # it will be created on the fly.
  def self.anonymous
    anonymous_role = where(builtin: BUILTIN_ANONYMOUS).first
    if anonymous_role.nil?
      anonymous_role = create(name: 'Anonymous', position: 0) do |role|
        role.builtin = BUILTIN_ANONYMOUS
      end
      raise 'Unable to create the anonymous role.' if anonymous_role.new_record?
    end
    anonymous_role
  end

  def self.by_permission(permission)
    all.select do |role|
      role.allowed_to? permission
    end
  end

  def self.paginated_search(search, options = {})
    paginate_scope! givable.like(search), options
  end

  private

  def allowed_permissions
    @allowed_permissions ||= permissions + Redmine::AccessControl.public_permissions.map(&:name)
  end

  def allowed_actions
    @actions_allowed ||= allowed_permissions.inject([]) { |actions, permission| actions += Redmine::AccessControl.allowed_actions(permission) }.flatten
  end

  def check_deletable
    raise "Can't delete role" if members.any?
    raise "Can't delete builtin role" if builtin?
  end

  def add_permission(permission)
    if persisted?
      role_permissions.create(permission: permission)
    else
      role_permissions.build(permission: permission)
    end
  end
end
