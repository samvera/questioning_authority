# Defines the external authority predicates used to extract additional context from the graph.
require 'ldpath'

module Qa
  module LinkedData
    module Config
      class ContextPropertyMap
        VALUE_ON_ERROR = [].freeze

        attr_reader :group_id, # id that identifies which group the property should be in
                    :label

        attr_reader :property_map, :ldpath, :expansion_label_ldpath, :expansion_id_ldpath, :prefixes
        private :property_map, :ldpath, :expansion_label_ldpath, :expansion_id_ldpath, :prefixes

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
          @expansion_label_ldpath = Qa::LinkedData::Config::Helper.fetch(property_map, :expansion_label_ldpath, nil)
          @expansion_id_ldpath = Qa::LinkedData::Config::Helper.fetch(property_map, :expansion_id_ldpath, nil)
          @prefixes = prefixes
        end

        # Can this property be the selected value?
        # @return [Boolean] true if this property's value can be selected; otherwise, false
        def selectable?
          @selectable
        end

        # Can this property be used as a new query
        # @return [Boolean] true if this property's value can be used to drill up/down to another level; otherwise, false
        def drillable?
          @drillable
        end

        def group?
          group_id.present?
        end

        # Should this URI value be expanded to include its label?
        # @return [Boolean] true if this property's value is expected to be a URI and its label should be included in the value; otherwise, false
        def expand_uri?
          expansion_label_ldpath.present?
        end

        # Values of this property for a specfic subject URI
        # @return [Array<String>] values for this property
        def values(graph, subject_uri)
          Qa::LinkedData::LdpathService.ldpath_evaluate(program: basic_program, graph: graph, subject_uri: subject_uri)
        end

        # Values of this property for a specfic subject URI with URI values expanded to include id and label.
        # @return [Array<Hash>] expanded values for this property
        # @example returned values
        #   [{
        #     uri: "http://id.loc.gov/authorities/genreForms/gf2014026551",
        #     id: "gf2014026551",
        #     label: "Space operas"
        #   }]
        def expanded_values(graph, subject_uri)
          values = values(graph, subject_uri)
          return values unless expand_uri?
          return values unless values.respond_to? :map!
          values.map! do |uri|
            { uri: uri, id: expansion_id(graph, uri), label: expansion_label(graph, uri) }
          end
          values
        end

        private

          def extract_label
            i18n_key = Qa::LinkedData::Config::Helper.fetch(property_map, :property_label_i18n, nil)
            default = Qa::LinkedData::Config::Helper.fetch(property_map, :property_label_default, nil)
            return I18n.t(i18n_key, default: default) if i18n_key.present?
            default
          end

          def basic_program
            @basic_program ||= Qa::LinkedData::LdpathService.ldpath_program(ldpath: ldpath, prefixes: prefixes)
          end

          def expansion_label_program
            @expansion_label_program ||= Qa::LinkedData::LdpathService.ldpath_program(ldpath: expansion_label_ldpath, prefixes: prefixes)
          end

          def expansion_id_program
            @expansion_id_program ||= Qa::LinkedData::LdpathService.ldpath_program(ldpath: expansion_id_ldpath, prefixes: prefixes)
          end

          def expansion_label(graph, uri)
            label = Qa::LinkedData::LdpathService.ldpath_evaluate(program: expansion_label_program, graph: graph, subject_uri: RDF::URI(uri))
            label.size == 1 ? label.first : label
          end

          def expansion_id(graph, uri)
            return uri if expansion_id_ldpath.blank?
            id = Qa::LinkedData::LdpathService.ldpath_evaluate(program: expansion_id_program, graph: graph, subject_uri: RDF::URI(uri))
            id.size == 1 ? id.first : id
          end
      end
    end
  end
end
