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

module Plugins
  module LoadPathHelper
    def self.spec_load_paths
      plugin_load_paths.map { |path|
        File.join(path, 'spec')
      }.keep_if{ |path| File.directory?(path) }
    end

    def self.cucumber_load_paths
      plugin_load_paths.map { |path|
        File.join(path, 'features')
      }.keep_if{ |path| File.directory?(path) }
    end

    private

    # fetch load paths for available plugins
    def self.plugin_load_paths
      Rails.application.config.plugins_to_test_paths.map(&:to_s)
    end
  end
end
