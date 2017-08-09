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
  module Utilities
    module PayloadRepresenter
      def self.included(base)
        base.extend(ClassMethods)

        base.representable_attrs.each do |property|
          if property.name == 'links'
            add_filter(property, link_render_block)
          elsif property[:writeable] == false
            property.merge!(readable: false)
          else
            add_filter(property, unwriteable_property_filter)
          end
        end
      end

      def self.unwriteable_property_filter
        ->(input, options) do
          writeable_attr = options[:decorator].writeable_attributes

          as = options[:binding][:as].()
          if writeable_attr.include?(as)
            input
          else
            ::Representable::Pipeline::Stop
          end
        end
      end

      def self.link_render_block
        ->(input, options) do
          writeable_attr = options[:decorator].writeable_attributes

          input.reject do |link|
            link.rel && !writeable_attr.include?(link.rel.to_s)
          end
        end
      end

      def self.add_filter(property, filter)
        property.merge!(render_filter: filter)
      end

      def from_hash(hash, *args)
        # Prevent entries in _embedded from overriding anything in the _links section
        copied_hash = hash.deep_dup

        copied_hash.delete('_embedded')

        super(copied_hash, *args)
      end

      def contract?(represented)
        contract_class(represented).present?
      end

      def writeable_attributes
        @writeable_attributes ||= begin
          contract = contract_class(represented)

          if contract
            contract
              .new(represented, current_user: current_user)
              .writable_attributes
              .map { |name| ::API::Utilities::PropertyNameConverter.from_ar_name(name) }
          else
            representable_attrs.map do |property|
              property[:as].()
            end
          end
        end
      end

      module ClassMethods
        def create_class(work_package)
          new_class = super

          new_class.send(:include, ::API::Utilities::PayloadRepresenter)

          new_class
        end
      end

      private

      def contract_class(represented)
        return nil unless represented && represented.respond_to?(:new_record?)

        contract_namespace = represented.class.name.pluralize

        contract_name = if represented.new_record?
                          "CreateContract"
                        else
                          "UpdateContract"
                        end

        begin
          "#{contract_namespace}::#{contract_name}".constantize
        rescue NameError
          nil
        end
      end
    end
  end
end
