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

require 'roar/decorator'
require 'roar/json/hal'

module API
  module Decorators
    class PropertySchemaRepresenter < ::API::Decorators::Single
      def initialize(
        type:, name:, required: true, has_default: false, writable: true,
        visibility: nil, attribute_group: nil, current_user: nil
      )
        @type = type
        @name = name
        @required = required
        @has_default = has_default
        @writable = writable
        @visibility = if visibility == false
                        nil
                      else
                        visibility || 'default'
                      end
        @attribute_group = attribute_group

        super(nil, current_user: current_user)
      end

      attr_accessor :type,
                    :name,
                    :required,
                    :has_default,
                    :writable,
                    :visibility,
                    :attribute_group,
                    :min_length,
                    :max_length,
                    :regular_expression

      property :type, exec_context: :decorator
      property :name, exec_context: :decorator
      property :required, exec_context: :decorator
      property :has_default, exec_context: :decorator
      property :writable, exec_context: :decorator
      property :visibility, exec_context: :decorator
      property :attribute_group, exec_context: :decorator
      property :min_length, exec_context: :decorator
      property :max_length, exec_context: :decorator
      property :regular_expression, exec_context: :decorator

      private

      def model_required?
        # we never pass a model to our superclass
        false
      end
    end
  end
end
