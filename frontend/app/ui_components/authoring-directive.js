//-- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2017 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
//++

// TODO move to UI components
module.exports = function(I18n, PathHelper, TimezoneService) {
  return {
    restrict: 'E',
    replace: true,
    scope: { createdOn: '=', author: '=', project: '=', activity: '=' },
    templateUrl: '/templates/components/authoring.html',
    link: function(scope, element, attrs) {
      moment.locale(I18n.locale);

      var createdOn = TimezoneService.parseDatetime(scope.createdOn);
      var timeago = createdOn.fromNow();
      var time = createdOn.format('LLL');

      function activityFromPath(project, from) {
        var path = PathHelper.projectActivityPath(project);

        if (from) {
          path += '?from=' + from;
        }

        return path;
      }

      scope.I18n = I18n;
      scope.authorLink = '<a href="'+ PathHelper.userPath(scope.author.id) + '">' + scope.author.name + '</a>';

      if (scope.activity) {
        scope.timestamp = '<a title="' + time + '" href="' + activityFromPath(scope.project, createdOn.format('YYYY-MM-DD')) + '">' + timeago + '</a>';
      } else {
        scope.timestamp = '<span class="timestamp" title="' + time + '">' + timeago + '</span>';
      }
    }
  };
};
