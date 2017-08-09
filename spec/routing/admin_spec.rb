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

describe 'admin routes', type: :routing do
  it 'connects GET /admin to admin#index' do
    expect(get('/admin'))
      .to route_to('admin#index')
  end

  it 'connects GET /admin/projects to admin#projects' do
    expect(get('/admin/projects'))
      .to route_to('admin#projects')
  end

  it 'connects GET /admin/plugins to admin#plugins' do
    expect(get('/admin/plugins'))
      .to route_to('admin#plugins')
  end

  it 'connects GET /admin/info to admin#info' do
    expect(get('/admin/info'))
      .to route_to('admin#info')
  end

  it 'connects POST /admin/force_user_language to admin#force_user_language' do
    expect(post('/admin/force_user_language'))
      .to route_to('admin#force_user_language')
  end

  it 'connects POST /admin/test_email to admin#test_email' do
    expect(post('/admin/test_email'))
      .to route_to('admin#test_email')
  end
end
