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

require_relative 'query_service'

class UpdateQueryService < QueryService
  self.contract = Queries::UpdateContract

  def call(query)
    initialize_contract! query

    result, errors = update query

    service_result result, errors, query
  end

  private

  def update(query)
    menu_item = prepare_menu_item query

    result = nil
    errors = nil

    query.transaction do
      result, errors = validate_and_save query

      if !result
        raise ActiveRecord::Rollback
      elsif menu_item && !menu_item.save
        result = false
        merge_errors(errors, menu_item)
      end
    end

    [result, errors]
  end

  def prepare_menu_item(query)
    if query.changes.include?('name') &&
       query.query_menu_item

      menu_item = query.query_menu_item

      menu_item.title = query.name

      menu_item
    end
  end

  def merge_errors(errors, menu_item)
    menu_item.errors.each do |sym, message|
      errors.add(sym, message)
    end
  end
end
