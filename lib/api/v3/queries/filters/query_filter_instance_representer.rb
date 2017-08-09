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
    module Queries
      module Filters
        class QueryFilterInstanceRepresenter < ::API::Decorators::Single
          include API::Decorators::LinkedResource

          def initialize(model)
            super(model, current_user: nil, embed_links: true)
          end

          link :schema do
            api_v3_paths.query_filter_instance_schema(converted_name)
          end

          resource_link :filter,
                        getter: ->(*) {
                          {
                            href: api_v3_paths.query_filter(converted_name),
                            title: name
                          }
                        },
                        setter: ->(**) {
                          # nothing for now, handled in QueryRepresenter
                        }

          resource_link :operator,
                        getter: ->(*) {
                          hash = {
                            href: api_v3_paths.query_operator(CGI.escape(represented.operator))
                          }

                          hash[:title] = represented.operator_class.human_name if represented.operator_class.present?
                          hash
                        },
                        setter: ->(fragment:, **) {
                          next unless fragment

                          represented.operator = ::API::Utilities::ResourceLinkParser
                                                 .parse_id fragment["href"],
                                                           property: 'operator',
                                                           expected_version: '3',
                                                           expected_namespace: 'queries/operators'
                        }

          resources :values,
                    link: ->(*) {
                      next unless represented.ar_object_filter?

                      represented.value_objects.map do |value_object|
                        {
                          href: api_v3_paths.send(value_object.class.name.demodulize.underscore, value_object.id),
                          title: value_object.name
                        }
                      end
                    },
                    setter: ->(fragment:, **) {
                      next unless fragment

                      if represented.ar_object_filter?
                        set_link_values(fragment)
                      else
                        set_property_values(fragment)
                      end
                    },
                    getter: ->(*) {
                      if represented.respond_to?(:custom_field) &&
                         represented.custom_field.field_format == 'bool'
                        represented.values.map do |value|
                          if value == CustomValue::BoolStrategy::DB_VALUE_TRUE
                            true
                          else
                            false
                          end
                        end
                      else
                        represented.values
                      end
                    },
                    skip_render: ->(*) { represented.ar_object_filter? },
                    embedded: false

          property :name,
                   exec_context: :decorator,
                   writeable: false

          def _type
            "#{converted_name.camelize}QueryFilter"
          end

          def name
            represented.human_name
          end

          def set_link_values(vals)
            represented.values = vals.map do |value|
              ::API::Utilities::ResourceLinkParser.parse(value["href"])[:id]
            end
          end

          def set_property_values(vals)
            represented.values = if represented.respond_to?(:custom_field) &&
                                    represented.custom_field.field_format == 'bool'
                                   vals.map do |value|
                                     if value
                                       CustomValue::BoolStrategy::DB_VALUE_TRUE
                                     else
                                       CustomValue::BoolStrategy::DB_VALUE_FALSE
                                     end
                                   end
                                 else
                                   vals
                                 end
          end

          def converted_name
            ::API::Utilities::PropertyNameConverter.from_ar_name(represented.name)
          end

          def query_filter_instance_links_representer(represented)
            ::API::V3::Queries::Filters::QueryFilterInstanceLinksRepresenter.new represented, current_user: current_user
          end
        end
      end
    end
  end
end
