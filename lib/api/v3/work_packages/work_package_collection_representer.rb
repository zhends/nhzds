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
require 'roar/json'
require 'roar/json/collection'
require 'roar/json/hal'

module API
  module V3
    module WorkPackages
      class WorkPackageCollectionRepresenter < ::API::Decorators::OffsetPaginatedCollection
        element_decorator ::API::V3::WorkPackages::WorkPackageRepresenter

        def initialize(models,
                       self_link,
                       query: {},
                       project: nil,
                       groups:,
                       total_sums:,
                       page: nil,
                       per_page: nil,
                       embed_schemas: false,
                       current_user:)
          @project = project
          @groups = groups
          @total_sums = total_sums
          @embed_schemas = embed_schemas

          super(models,
                self_link,
                query: query,
                page: page,
                per_page: per_page,
                current_user: current_user)

          # In order to optimize performance we
          #   * override paged_models so that only the id is fetched from the
          #     scope (typically a query with a couple of includes for e.g.
          #     filtering), circumventing AR instantiation alltogether
          #   * use the ids to fetch the actual work packages with all the fields
          #     necessary for rendering the work packages in _elements
          #
          # This results in the weird flow where the scope is passed to super (models variable),
          # which calls the overriden paged_models method fetching the ids. In order to have
          # real AR objects again, we finally get the work packages we actually want to have
          # and set those to be the represented collection.
          # A potential ordering is reapplied to the work package collection in ruby.

          @represented = full_work_packages(represented)
        end

        link :sumsSchema do
          {
            href: api_v3_paths.work_package_sums_schema
          } if total_sums || groups && groups.any?(&:has_sums?)
        end

        link :createWorkPackage do
          {
            href: api_v3_paths.create_work_package_form,
            method: :post
          } if current_user_allowed_to_add_work_packages?
        end

        link :createWorkPackageImmediate do
          {
            href: api_v3_paths.work_packages,
            method: :post
          } if current_user_allowed_to_add_work_packages?
        end

        link :schemas do
          {
            href: schemas_path
          } if represented.any?
        end

        link :customFields do
          if project.present? &&
              (current_user.try(:admin?) || current_user_allowed_to(:edit_project, context: project))
            {
              href: settings_project_path(project.identifier, tab: 'custom_fields'),
              type: 'text/html',
              title: I18n.t('label_custom_field_plural')
            }
          end
        end

        links :representations do
          representation_formats if current_user.allowed_to?(:export_work_packages, project, global: project.nil?)
        end

        collection :elements,
                   getter: -> (*) {
                     generated_classes = ::Hash.new do |hash, work_package|
                       hit = hash.values.find do |klass|
                         klass.customizable.type_id == work_package.type_id &&
                           klass.customizable.project_id == work_package.project_id
                       end

                       hash[work_package] = hit || element_decorator.create_class(work_package)
                     end

                     represented.map do |model|
                       generated_classes[model].new(model, current_user: current_user)
                     end
                   },
                   exec_context: :decorator,
                   embedded: true

        property :schemas,
                 exec_context: :decorator,
                 if: ->(*) { embed_schemas && represented.any? },
                 embedded: true,
                 render_nil: false

        property :groups,
                 exec_context: :decorator,
                 render_nil: false

        property :total_sums,
                 exec_context: :decorator,
                 getter: ->(*) {
                   if total_sums
                     ::API::V3::WorkPackages::WorkPackageSumsRepresenter.create(total_sums)
                   end
                 },
                 render_nil: false

        def current_user_allowed_to_add_work_packages?
          current_user.allowed_to?(:add_work_packages, project, global: project.nil?)
        end

        def schemas
          schemas = schema_pairs.map do |project, type|
            Schema::TypedWorkPackageSchema.new(project: project, type: type)
          end

          Schema::WorkPackageSchemaCollectionRepresenter.new(schemas,
                                                             schemas_path,
                                                             current_user: current_user)
        end

        def schemas_path
          ids = schema_pairs.map do |project, type|
            [project.id, type.id]
          end

          api_v3_paths.work_package_schemas(*ids)
        end

        def schema_pairs
          represented
            .map { |work_package| [work_package.project, work_package.type] }
            .uniq
        end

        def add_eager_loading(scope, current_user)
          scope
            .includes(element_decorator.to_eager_load)
            .include_spent_hours(current_user)
            .select('work_packages.*')
        end

        def paged_models(models)
          models.page(@page).per_page(@per_page).pluck(:id)
        end

        def full_work_packages(ids_in_order)
          wps = add_eager_loading(WorkPackage.where(id: ids_in_order), current_user).to_a

          eager_load_ancestry(wps, ids_in_order)
          eager_load_user_custom_values(wps)
          eager_load_version_custom_values(wps)
          eager_load_list_custom_values(wps)

          wps.sort_by { |wp| ids_in_order.index(wp.id) }
        end

        def eager_load_ancestry(work_packages, ids_in_order)
          grouped = WorkPackage.aggregate_ancestors(ids_in_order, current_user)

          work_packages.each do |wp|
            wp.work_package_ancestors = grouped[wp.id] || []
          end
        end

        def eager_load_user_custom_values(work_packages)
          eager_load_custom_values work_packages, 'user', User.includes(:preference)
        end

        def eager_load_version_custom_values(work_packages)
          eager_load_custom_values work_packages, 'version', Version
        end

        def eager_load_list_custom_values(work_packages)
          eager_load_custom_values work_packages, 'list', CustomOption
        end

        def eager_load_custom_values(work_packages, field_format, scope)
          cvs = custom_values_of(work_packages, field_format)

          ids_of_values = cvs.map(&:value).select { |v| v =~ /\A\d+\z/ }

          values_by_id = scope.find(ids_of_values).group_by(&:id)

          cvs.each do |cv|
            next unless values_by_id[cv.value.to_i]
            cv.value = values_by_id[cv.value.to_i].first
          end
        end

        def custom_values_of(work_packages, field_format)
          cvs = []

          work_packages.each do |wp|
            wp.custom_values.each do |cv|
              cvs << cv if cv.custom_field.field_format == field_format && cv.value.present?
            end
          end

          cvs
        end

        def _type
          'WorkPackageCollection'
        end

        def representation_formats
          formats = [
            representation_format_pdf,
            representation_format_pdf_description,
            representation_format_csv
          ]

          if Setting.feeds_enabled?
            formats << representation_format_atom
          end

          formats
        end

        def representation_format(identifier, mime_type:, format: identifier, i18n_key: format, url_query_extras: nil)
          path_params = { controller: :work_packages, action: :index, project_id: project }

          href = "#{url_for(path_params.merge(format: format))}?#{href_query(@page, @per_page)}"

          if url_query_extras
            href += "&#{url_query_extras}"
          end

          {
            href: href,
            identifier: identifier,
            type: mime_type,
            title: I18n.t("export.format.#{i18n_key}")
          }
        end

        def representation_format_pdf
          representation_format 'pdf',
                                mime_type: 'application/pdf'
        end

        def representation_format_pdf_description
          representation_format 'pdf-with-descriptions',
                                format: 'pdf',
                                i18n_key: 'pdf_with_descriptions',
                                mime_type: 'application/pdf',
                                url_query_extras: 'show_descriptions=true'
        end

        def representation_format_csv
          representation_format 'csv',
                                mime_type: 'text/csv'
        end

        def representation_format_atom
          representation_format 'atom',
                                mime_type: 'application/atom+xml'
        end

        attr_reader :project,
                    :groups,
                    :total_sums,
                    :embed_schemas
      end
    end
  end
end
