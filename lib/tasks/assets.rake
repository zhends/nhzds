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

# Based on a Snippet by Tom Dooner. See:
# http://www.tomdooner.com/2014/05/26/webpack.html

# The webpack task must run before assets:environment task.
# Otherwise Sprockets cannot find the files that webpack produces.
Rake::Task['assets:precompile']
  .clear_prerequisites
  .enhance(['assets:compile_environment', 'assets:prepare_op'])

namespace :assets do
  # In this task, set prerequisites for the assets:precompile task
  task compile_environment: :prepare_op do
    Rake::Task['assets:environment'].invoke
  end

  desc 'Prepare locales and webpack assets'
  task prepare_op: [:webpack, :export_locales]

  desc 'Compile assets with webpack'
  task :webpack do
    Dir.chdir Rails.root.join('frontend') do
      sh '$(npm bin)/webpack --config webpack.production.config.js'
    end
  end

  desc 'Export frontend locale files'
  task export_locales: ['i18n:js:export']

  task :clobber do
    rm_rf FileList["#{Rails.root}/app/assets/javascripts/bundles/*"]
  end
end
