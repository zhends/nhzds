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

class CreateTimelinesPlanningElementTypes < ActiveRecord::Migration[4.2]
  def self.up
    create_table(:timelines_planning_element_types) do |t|
      t.column :name,         :string,  null: false

      t.column :in_aggregation, :boolean, default: true,  null: false
      t.column :is_milestone,   :boolean, default: false, null: false
      t.column :is_default,     :boolean, default: false, null: false

      t.column :position,     :integer, default: 1,     null: false

      t.belongs_to :color
      t.belongs_to :project_type

      t.timestamps
    end

    add_index :timelines_planning_element_types, :color_id
    add_index :timelines_planning_element_types, :project_type_id
  end

  def self.down
    drop_table(:timelines_planning_element_types)
  end
end
