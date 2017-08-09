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

class ReportedProjectStatusesController < ApplicationController
  helper :timelines

  before_action :disable_api
  before_action :determine_base
  accept_key_auth :index, :show

  def index
    @reported_project_statuses = @base
    respond_to do |format|
      format.html do render_404 end
    end
  end

  def show
    @reported_project_status = @base.find(params[:id])
    respond_to do |format|
      format.html do render_404 end
    end
  end

  protected

  def determine_base
    if params[:project_type_id]
      @base = ProjectType.find(params[:project_type_id]).reported_project_statuses.active
    else
      @base = ReportedProjectStatus.active
    end
  end
end
