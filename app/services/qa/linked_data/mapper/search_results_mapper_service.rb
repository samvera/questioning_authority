# Provide service for mapping graph to json limited to configured fields and context.
module Qa
  module LinkedData
    module Mapper
      class SearchResultsMapperService
        class_attribute :graph_ldpath_mapper_service, :graph_predicate_mapper_service, :deep_sort_service, :context_mapper_service
        self.graph_ldpath_mapper_service = Qa::LinkedData::Mapper::GraphLdpathMapperService
        self.graph_predicate_mapper_service = Qa::LinkedData::Mapper::GraphPredicateMapperService
        self.deep_sort_service = Qa::LinkedData::DeepSortService
        self.context_mapper_service = Qa::LinkedData::Mapper::ContextMapperService

        class << self
          # Extract predicates specified in the predicate_map from the graph and return as an array of value maps for each search result subject URI.
          # If a sort key is present, a subject will only be included in the results if it has a statement with the sort predicate.
          # @param graph [RDF::Graph] the graph from which to extract result values
          # @param prefixes [Hash<Symbol><String>] URL map of prefixes to use with ldpaths
          # @example prefixes
          #   {
          #     locid: 'http://id.loc.gov/vocabulary/identifiers/',
          #     skos: 'http://www.w3.org/2004/02/skos/core#',
          #     vivo: 'http://vivoweb.org/ontology/core#'
          #   }
          # @param ldpath [Hash<Symbol><String||Symbol>] value either maps to a ldpath in the graph or is :subject_uri indicating to use the subject uri as the value
          # @example ldpath map
          #   {
          #     uri: :subject_uri,
          #     id: 'locid:lccn :: xsd::string',
          #     label: 'skos:prefLabel :: xsd::string',
          #     altlabel: 'skos:altLabel :: xsd::string',
          #     sort: 'vivo:rank :: xsd::integer'
          #   }
          # @param predicate_map [Hash<Symbol><String||Symbol>] value either maps to a predicate in the graph or is :subject_uri indicating to use the subject uri as the value
          # @example predicate map
          #   {
          #     uri: :subject_uri,
          #     id: 'http://id.loc.gov/vocabulary/identifiers/lccn',
          #     label: 'http://www.w3.org/2004/02/skos/core#prefLabel',
          #     altlabel: 'http://www.w3.org/2004/02/skos/core#altLabel',
          #     sort: 'http://vivoweb.org/ontology/core#rank'
          #   }
          # @param sort_key [Symbol] the key in the predicate map for the value on which to sort
          # @param preferred_language [Array<Symbol>] sort multiple literals for a value with preferred language first
          # @param context_map [Qa::LinkedData::Config::ContextMap] map of additional context to include in the results
          # @return [Array<Hash<Symbol><Array<Object>>>] mapped result values with each result as an element in the array
          #    with hash of map key = array of object values for predicates identified in map parameter.
          # @example value map for a single result
          #   [
          #     { "uri":"http://id.loc.gov/authorities/genreForms/gf2011026181","id":"gf2011026181","label":"Stop-motion animation films",
          #       "context":[
          #         { "property":"Authoritative Label","values":["Stop-motion animation films"],"selectable":true,"drillable":false },
          #         { "property":"Variant Label","values":["Object animation films, Frame-by-frame animation films"],"selectable":false,"drillable":false },
          #         { "group":"Hierarchy","property":"Narrower: ",
          #           "values":[
          #             { "uri":"http://id.loc.gov/authorities/genreForms/gf2011026140","id":"gf2011026140","label":"Clay animation films"}
          #           ],
          #           "selectable":true,"drillable":true },
          #         { "group":"Hierarchy","property":"Broader: ",
          #           "values":[
          #             { "uri":"http://id.loc.gov/authorities/genreForms/gf2011026049","id":"gf2011026049","label":"Animated films"}
          #           ],
          #           "selectable":true,"drillable":true }
          #       ]
          #     }
          #   ]
          def map_values(graph:, prefixes: {}, ldpath_map: nil, predicate_map: nil, sort_key:, preferred_language: nil, context_map: nil) # rubocop:disable Metrics/ParameterLists
            search_matches = []
            graph.subjects.each do |subject|
              next if subject.anonymous? # skip blank nodes
              values = if ldpath_map.present?
                         map_values_with_ldpath_map(graph: graph, ldpath_map: ldpath_map, prefixes: prefixes, subject_uri: subject, sort_key: sort_key, context_map: context_map)
                       else
                         map_values_with_predicate_map(graph: graph, predicate_map: predicate_map, subject_uri: subject, sort_key: sort_key, context_map: context_map)
                       end
              search_matches << values if result_subject? values, sort_key
            end
            search_matches = deep_sort_service.new(search_matches, sort_key, preferred_language).sort
            search_matches
          end

          private

            # The graph mapper creates the basic value_map for all subject URIs, but we only want the ones that represent search results.
            def result_subject?(value_map, sort_key)
              return true unless sort_key.present?        # if sort_key is not defined, then all subjects are considered matches
              return false unless value_map.key? sort_key # otherwise, sort_key must be in the basic value_map
              value_map[sort_key].present?                # AND have a value for this to be a search result
            end

            def map_context(graph, sort_key, context_map, value_map, subject)
              return value_map if context_map.blank?
              return value_map unless result_subject? value_map, sort_key
              context = {}
              context = context_mapper_service.map_context(graph: graph, context_map: context_map, subject_uri: subject) if context_map.present?
              value_map[:context] = context
              value_map
            end

            def map_values_with_ldpath_map(graph:, ldpath_map:, prefixes:, subject_uri:, sort_key:, context_map:) # rubocop:disable Metrics/ParameterLists
              graph_ldpath_mapper_service.map_values(graph: graph, ldpath_map: ldpath_map, prefixes: prefixes, subject_uri: subject_uri) do |value_map|
                map_context(graph, sort_key, context_map, value_map, subject_uri)
              end
            end

            def map_values_with_predicate_map(graph:, predicate_map:, subject_uri:, sort_key:, context_map:)
              Qa.deprecation_warning(
                in_msg: 'Qa::LinkedData::Mapper::SearchResultsMapperService',
                msg: 'predicate_map is deprecated; update to use ldpath_map'
              )
              graph_predicate_mapper_service.map_values(graph: graph, predicate_map: predicate_map, subject_uri: subject_uri) do |value_map|
                map_context(graph, sort_key, context_map, value_map, subject_uri)
              end
            end
        end
      end
    end
  end
end
