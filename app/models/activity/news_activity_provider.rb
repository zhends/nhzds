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

class Activity::NewsActivityProvider < Activity::BaseActivityProvider
  acts_as_activity_provider type: 'news',
                            permission: :view_news

  def extend_event_query(_query, _activity)
  end

  def event_query_projection(activity)
    [
      activity_journal_projection_statement(:title, 'title', activity),
      activity_journal_projection_statement(:project_id, 'project_id', activity)
    ]
  end

  protected

  def event_title(event, _activity)
    event['title']
  end

  def event_type(_event, _activity)
    'news'
  end

  def event_path(event, _activity)
    url_helpers.news_path(url_helper_parameter(event))
  end

  def event_url(event, _activity)
    url_helpers.news_url(url_helper_parameter(event))
  end

  private

  def url_helper_parameter(event)
    event['journable_id']
  end
end
