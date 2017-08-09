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

class AddTimelinesProjectTypeIdToProjects < ActiveRecord::Migration[4.2]
  def self.up
    change_table(:projects) do |t|
      t.belongs_to :timelines_project_type

      t.index :timelines_project_type_id
    end
  rescue
    raise "Error: Cannot migrate table 'projects'!"\
          "\n\n"\
          "Chances are high that this schema was modified by the plug-in 'Timelines':\n"\
          "You may use the rake task 'migrations:timelines:reregister' to prepare the\n"\
          'current schema for this migration.'\
          "\n\n\n"
  end

  def self.down
    change_table(:projects) do |t|
      t.remove_belongs_to :timelines_project_type
    end
  end
end
