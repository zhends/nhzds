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

module API
  module V3
    module Schemas
      class SchemaCollectionRepresenter <
        ::API::Decorators::UnpaginatedCollection

        def initialize(represented, self_link, current_user:, form_embedded: false)
          self.form_embedded = form_embedded

          super(represented, self_link, current_user: current_user)
        end

        collection :elements,
                   getter: ->(*) {
                     represented.map do |model|
                       self_link = model_self_link(model)

                       element_decorator.create(model,
                                                self_link,
                                                current_user: current_user,
                                                form_embedded: form_embedded)
                     end
                   },
                   exec_context: :decorator,
                   embedded: true

        private

        attr_accessor :form_embedded

        def model_self_link(_model)
          raise NotImplementedError, 'Subclass has to implement this'
        end
      end
    end
  end
end
