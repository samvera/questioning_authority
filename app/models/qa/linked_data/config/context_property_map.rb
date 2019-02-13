# Defines the external authority predicates used to extract additional context from the graph.
require 'ldpath'

module Qa
  module LinkedData
    module Config
      class ContextPropertyMap
        attr_reader :group_id, # id that identifies which group the property should be in
                    :label # plain text label extracted from locales or using the default

        attr_reader :property_map, :ldpath, :prefixes
        private :property_map, :ldpath, :prefixes

        # @param [Hash] property_map defining information to return to provide context
        # @option property_map [String] :group_id (optional) default label to use for a property (default: no label)
        # @option property_map [String] :property_label_i18n (optional) i18n key to use to get the label for a property (default: property_label_default OR no label if neither are defined)
        # @option property_map [String] :property_label_default (optional) default label to use for a property (default: no label)
        # @option property_map [String] :ldpath (required) identifies the values to extract from the graph (based on http://marmotta.apache.org/ldpath/language.html)
        # @option property_map [Boolean] :selectable (optional) if true, this property can selected as the value (default: false)
        # @option property_map [Boolean] :drillable (optional) if true, the label for this property can be used to execute a second query allowing navi (default: false)
        # @param [Hash] shortcut names for URI prefixes with key = part of predicate that is the same for all terms (e.g. { "madsrdf": "http://www.loc.gov/mads/rdf/v1#" })
        # @example property_map example
        #   {
        #     "group_id": "dates",
        #     "property_label_i18n": "qa.linked_data.authority.locnames_ld4l_cache.birth_date",
        #     "property_label_default": "Birth",
        #     "ldpath": "madsrdf:identifiesRWO/madsrdf:birthDate/schema:label",
        #     "selectable": false,
        #     "drillable": false
        #   }
        def initialize(property_map = {}, prefixes = {})
          @property_map = property_map
          @group_id = Qa::LinkedData::Config::Helper.fetch_symbol(property_map, :group_id, nil)
          @label = extract_label
          @ldpath = Qa::LinkedData::Config::Helper.fetch_required(property_map, :ldpath, false)
          @selectable = Qa::LinkedData::Config::Helper.fetch_boolean(property_map, :selectable, false)
          @drillable = Qa::LinkedData::Config::Helper.fetch_boolean(property_map, :drillable, false)
          @prefixes = prefixes
        end

        # Can this property be the selected value?
        # @return true if can be selected; otherwise, false
        def selectable?
          @selectable
        end

        # Can this property be used as a new query
        # @return true if can be selected; otherwise, false
        def drillable?
          @drillable
        end

        def values(graph, subject_uri)
          output = ldpath_program.evaluate subject_uri, graph
          output.present? ? output['property'].uniq : nil
        rescue
          'PARSE ERROR'
        end

        def group?
          group_id.present?
        end

        private

          def extract_label
            i18n_key = Qa::LinkedData::Config::Helper.fetch(property_map, :property_label_i18n, nil)
            default = Qa::LinkedData::Config::Helper.fetch(property_map, :property_label_default, nil)
            return I18n.t(i18n_key, default: default) if i18n_key.present?
            default
          end

          def ldpath_program
            return @program if @program.present?
            program_code = ""
            prefixes.each { |key, url| program_code << "@prefix #{key} : <#{url}> \;\n" }
            program_code << "property = #{ldpath} \;"
            @program = Ldpath::Program.parse program_code
          end
      end
    end
  end
end
