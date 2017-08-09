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

require 'fileutils'

desc 'Package up a OpenProject release from git. example: `rake release[1.1.0]`'
task :release, [:version] do |_task, args|
  version = args[:version]
  abort 'Missing version in the form of 1.0.0' unless version.present?

  dir = Pathname.new(ENV['HOME']) + 'dev' + 'openproject' + 'packages'
  FileUtils.mkdir_p dir

  commands = [
    "cd #{dir}",
    "git clone git://github.com/opf/openproject.git openproject-#{version}",
    "cd openproject-#{version}/",
    "git checkout v#{version}",
    "rm -vRf #{dir}/openproject-#{version}/.git",
    "cd #{dir}",
    "tar -zcvf openproject-#{version}.tar.gz openproject-#{version}",
    "zip -r -9 openproject-#{version}.zip openproject-#{version}",
    "md5sum openproject-#{version}.tar.gz openproject-#{version}.zip > openproject-#{version}.md5sum",
    "echo 'Release ready'"
  ].join(' && ')
  system(commands)
end
