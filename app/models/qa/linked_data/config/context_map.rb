# Defines the external authority predicates used to extract additional context from the graph.
module Qa
  module LinkedData
    module Config
      class ContextMap
        attr_reader :properties # [Array<Qa::LinkedData::Config::ContextPropertyMap>] set of property map models

        attr_reader :context_map, :groups, :prefixes
        private :context_map, :groups, :prefixes

        # @param [Hash] context_map that defines groups and properties for additional context to display during the selection process
        # @option context_map [Hash] :groups (optional) predefine group ids and labels to be used in the properties section to group properties
        # @option groups [Hash] key=group_id; value=[Hash] with group_label_i18n and/or group_label_default
        # @option context_map [Array<Hash>] :properties (optional) property maps defining how to get and display the additional context (if none, context will not be added)
        # @param [Hash] shortcut names for URI prefixes with key = part of predicate that is the same for all terms (e.g. { "madsrdf": "http://www.loc.gov/mads/rdf/v1#" })
        # @example context_map example
        #   {
        #     "groups": {
        #       "dates": {
        #         "group_label_i18n": "qa.linked_data.authority.locnames_ld4l_cache.dates",
        #         "group_label_default": "Dates"
        #       }
        #     },
        #     "properties": [
        #       {
        #         "property_label_i18n": "qa.linked_data.authority.locgenres_ld4l_cache.authoritative_label",
        #         "property_label_default": "Authoritative Label",
        #         "ldpath": "madsrdf:authoritativeLabel",
        #         "selectable": true,
        #         "drillable": false
        #       },
        #       {
        #         "group_id": "dates",
        #         "property_label_i18n": "qa.linked_data.authority.locnames_ld4l_cache.birth_date",
        #         "property_label_default": "Birth",
        #         "ldpath": "madsrdf:identifiesRWO/madsrdf:birthDate/schema:label",
        #         "selectable": false,
        #         "drillable": false
        #       }
        #     ]
        #   }
        def initialize(context_map = {}, prefixes = {})
          @context_map = context_map
          @prefixes = prefixes
          extract_groups
          extract_properties
        end

        def group_label(group_id)
          groups[group_id]
        end

        private

          def extract_properties
            @properties = []
            properties_map = Qa::LinkedData::Config::Helper.fetch(context_map, :properties, {})
            properties_map.each { |property_map| @properties << ContextPropertyMap.new(property_map, prefixes) }
          end

          def extract_groups
            @groups = {}
            groups_map = Qa::LinkedData::Config::Helper.fetch(context_map, :groups, {})
            groups_map.each { |group_id, group_map| add_group(group_id, group_map) }
          end

          def add_group(group_id, group_map)
            return if groups.key? group_id
            i18n_key = Qa::LinkedData::Config::Helper.fetch(group_map, :group_label_i18n, nil)
            default = Qa::LinkedData::Config::Helper.fetch(group_map, :group_label_default, nil)
            return groups[group_id] = I18n.t(i18n_key, default) if i18n_key.present?
            groups[group_id] = default
          end
      end
    end
  end
end
