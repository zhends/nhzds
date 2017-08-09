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

class TimelineOptionsToHash < ActiveRecord::Migration[5.0]
  class TimelineWithWhatever < ActiveRecord::Base
    self.table_name = :timelines

    serialize :options
  end

  class TimelineWithHash < ActiveRecord::Base
    self.table_name = :timelines

    serialize :options, Hash
  end

  def up
    TimelineWithWhatever.transaction do
      TimelineWithWhatever.all.to_a.each do |timeline|
        options = timeline.options
        next unless options && options.is_a?(ActionController::Parameters)
        options.permit!
        options = options.to_h

        TimelineWithHash
          .where(id: timeline.id)
          .update_all(options: options)
      end
    end
  end

  # This migration does not need to be rolled back because
  # it only harmonizes the possible values of the options attribute.
end
