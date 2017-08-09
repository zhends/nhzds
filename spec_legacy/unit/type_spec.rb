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
require 'type'

describe ::Type, type: :model do
  fixtures :all

  it 'should copy workflows' do
    source = ::Type.find(1)
    assert_equal 89, source.workflows.size

    target = ::Type.new(name: 'Target')
    assert target.save
    target.workflows.copy_from_type(source)
    target.reload
    assert_equal 89, target.workflows.size
  end

  it 'should statuses' do
    type = ::Type.find(1)
    Workflow.delete_all
    Workflow.create!(role_id: 1, type_id: 1, old_status_id: 2, new_status_id: 3)
    Workflow.create!(role_id: 2, type_id: 1, old_status_id: 3, new_status_id: 5)

    expect(type.statuses).to all be_kind_of Status
    assert_equal [2, 3, 5], ::Type.find(1).statuses.map(&:id)
  end

  it 'should statuses empty' do
    Workflow.where(type_id: 1).delete_all
    assert_equal [], ::Type.find(1).statuses
  end
end
