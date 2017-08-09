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

Feature: Former Passwords are banned from reuse
    Scenario: A user trying to reuse two former passwords
        Given users are not allowed to reuse the last 2 passwords
        And I am logged in
        When I try to set my new password to "adminADMIN!"
        Then there should be an error message
        When I try to set my new password to "adminADMIN!New"
        Then the password change should succeed
        When I try to change my password from "adminADMIN!New" to "adminADMIN!Third"
        Then the password change should succeed
        When I try to change my password from "adminADMIN!Third" to "adminADMIN!Third"
        Then there should be an error message
        When I try to change my password from "adminADMIN!Third" to "adminADMIN!New"
        Then there should be an error message
        When I try to change my password from "adminADMIN!Third" to "adminADMIN!"
        Then the password change should succeed

    Scenario: Former passwords are allowed
        Given users are not allowed to reuse the last 0 passwords
        And I am logged in
        When I try to set my new password to "adminADMIN!"
        Then the password change should succeed
