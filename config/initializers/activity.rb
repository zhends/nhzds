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

Redmine::Activity.map do |activity|
  activity.register :work_packages, class_name: 'Activity::WorkPackageActivityProvider'
  activity.register :changesets, class_name: 'Activity::ChangesetActivityProvider'
  activity.register :news, class_name: 'Activity::NewsActivityProvider',
                           default: false
  activity.register :wiki_edits, class_name: 'Activity::WikiContentActivityProvider',
                                 default: false
  activity.register :messages, class_name: 'Activity::MessageActivityProvider',
                               default: false
  activity.register :time_entries, class_name: 'Activity::TimeEntryActivityProvider',
                                   default: false
end

Project.register_latest_project_activity on: WorkPackage,
                                         attribute: :updated_at

Project.register_latest_project_activity on: News,
                                         attribute: :created_on

Project.register_latest_project_activity on: Changeset,
                                         chain: Repository,
                                         attribute: :committed_on

Project.register_latest_project_activity on: WikiContent,
                                         chain: [Wiki, WikiPage],
                                         attribute: :updated_on

Project.register_latest_project_activity on: Message,
                                         chain: Board,
                                         attribute: :updated_on

Project.register_latest_project_activity on: TimeEntry,
                                         attribute: :updated_on
