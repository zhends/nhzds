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

require 'spec_helper'

describe TimelogController, type: :routing do
  it 'should connect GET /work_packages/:work_package_id/time_entries/new to timelog#new' do
    expect(get('/work_packages/1/time_entries/new')).to route_to(controller: 'timelog',
                                                                 action: 'new',
                                                                 work_package_id: '1')
  end

  it 'connects GET /time_entries to timelog#index' do
    expect(get('/time_entries')).to route_to(controller: 'timelog',
                                             action: 'index')
  end

  it 'connects GET /projects/:id/time_entries to timelog#index' do
    expect(get('/projects/1/time_entries')).to route_to(controller: 'timelog',
                                                        action: 'index',
                                                        project_id: '1')
  end
end
