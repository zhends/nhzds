// -- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
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
// ++

function notificationBox($timeout, I18n, ConfigurationService) {
  var notificationBoxController = function(scope, element) {
    scope.uploadCount = 0;
    scope.show = false;
    scope.I18n = I18n;

    scope.canBeHidden = function() {
      return scope.content.uploads.length > 5;
    };

    scope.removable = function() {
      return scope.content.type !== 'upload';
    };

    scope.typeable = function() {
      return !!scope.content.type;
    };

    scope.remove = function() {
      if (scope.removable()) {
        scope.$emit('notification.remove', scope.content);
      }
    };

    /**
     * Execute the link callback from content.link.target
     * and close this notification.
     */
    scope.executeTarget = function() {
      scope.content.link.target();
      scope.remove();
    };

    scope.$on('upload.error', function() {
      if (scope.content.type === 'upload') {
        scope.content.type = 'error';
      }
    });

    scope.$on('upload.finished', function() {
      scope.uploadCount += 1;
    });
  };

  return {
    restrict: 'E',
    replace: true,
    templateUrl: '/components/common/notification-box/notification-box.directive.html',
    scope: {
      content: '='
    },
    link: notificationBoxController
  };
}

angular
  .module('openproject.uiComponents')
  .directive('notificationBox', notificationBox);
