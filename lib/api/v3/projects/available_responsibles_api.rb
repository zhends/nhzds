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

require 'api/v3/users/user_collection_representer'

module API
  module V3
    module Projects
      class AvailableResponsiblesAPI < ::API::OpenProjectAPI
        resource :available_responsibles do
          before do
            authorize(:view_work_packages, global: true, user: current_user)
          end

          get do
            available_responsibles = @project.possible_responsibles.includes(:preference)
            self_link = api_v3_paths.available_responsibles(@project.id)
            Users::UserCollectionRepresenter.new(available_responsibles,
                                                 self_link,
                                                 current_user: current_user)
          end
        end
      end
    end
  end
end
