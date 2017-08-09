#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
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
module DemoData
  class CustomFieldSeeder < Seeder
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def seed_data!
      # Careful: The seeding recreates the seeded project before it runs, so any changes
      # on the seeded project will be lost.
      print '    ↳ Creating custom fields...'

      # create some custom fields and add them to the project
      I18n.t('seeders.demo_data.custom_fields.names').each do |name|
        cf = WorkPackageCustomField.create!(name: name,
                                            regexp: '',
                                            is_required: false,
                                            min_length: false,
                                            default_value: '',
                                            max_length: false,
                                            editable: true,
                                            possible_values: '',
                                            visible: true,
                                            field_format: 'text')
        print '.'

        project.work_package_custom_fields << cf
      end

      puts
    end

    def applicable?
      not WorkPackageCustomField.any?
    end
  end
end
