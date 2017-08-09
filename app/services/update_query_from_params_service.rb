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

class UpdateQueryFromParamsService
  def initialize(query, user)
    self.query = query
    self.current_user = user
  end

  def call(params)
    apply_group_by(params)

    apply_sort_by(params)

    apply_filters(params)

    apply_columns(params)

    apply_sums(params)

    apply_timeline(params)

    apply_hierarchy(params)

    disable_hierarchy_when_only_grouped_by(params)

    if query.valid?
      ServiceResult.new(success: true,
                        result: query)
    else
      ServiceResult.new(errors: query.errors)
    end
  end

  private

  def apply_group_by(params)
    query.group_by = params[:group_by] if params[:group_by]
  end

  def apply_sort_by(params)
    query.sort_criteria = params[:sort_by] if params[:sort_by]
  end

  def apply_filters(params)
    return unless params[:filters]
    query.filters = []

    params[:filters].each do |filter|
      query.add_filter(filter[:field], filter[:operator], filter[:values])
    end
  end

  def apply_columns(params)
    query.column_names = params[:columns] if params[:columns]
  end

  def apply_sums(params)
    query.display_sums = params[:display_sums] if params.key?(:display_sums)
  end

  def apply_timeline(params)
    query.timeline_visible = params[:timeline_visible] if params.key?(:timeline_visible)
    query.timeline_zoom_level = params[:timeline_zoom_level] if params.key?(:timeline_zoom_level)
  end

  def apply_hierarchy(params)
    query.show_hierarchies = params[:show_hierarchies] if params.key?(:show_hierarchies)
  end

  def disable_hierarchy_when_only_grouped_by(params)
    if params.key?(:group_by) && !params.key?(:show_hierarchies)
      query.show_hierarchies = false
    end
  end

  attr_accessor :query,
                :current_user,
                :params
end
