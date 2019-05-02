# Provide service for mapping graph to json limited to configured fields and context.
module Qa
  module LinkedData
    module Mapper
      class TermResultsMapperService
        class_attribute :graph_ldpath_mapper_service, :graph_predicate_mapper_service
        self.graph_ldpath_mapper_service = Qa::LinkedData::Mapper::GraphLdpathMapperService
        self.graph_predicate_mapper_service = Qa::LinkedData::Mapper::GraphPredicateMapperService

        class << self
          # Extract predicates specified in the predicate_map from the graph and return as an array of value maps for each search result subject URI.
          # If a sort key is present, a subject will only be included in the results if it has a statement with the sort predicate.
          # @param graph [RDF::Graph] the graph from which to extract result values
          # @param subject_uri [RDF::URI] the uri of the term represented by the graph
          # @param prefixes [Hash<Symbol><String>] URL map of prefixes to use with ldpaths
          # @example prefixes
          #   {
          #     locid: 'http://id.loc.gov/vocabulary/identifiers/',
          #     skos: 'http://www.w3.org/2004/02/skos/core#',
          #   }
          # @param ldpath [Hash<Symbol><String||Symbol>] value either maps to a ldpath in the graph or is :subject_uri indicating to use the subject uri as the value
          # @example ldpath map
          #   {
          #     uri: :subject_uri,
          #     id: 'locid:lccn :: xsd::string',
          #     label: 'skos:prefLabel :: xsd::string',
          #     altlabel: 'skos:altLabel :: xsd::string',
          #     broader:  'skos:broader :: xsd::anyURI',
          #     narrower: 'skos:narrower :: xsd::anyURI',
          #     sameas: 'skos:exactMatch :: xsd::anyURI'
          #   }
          # @param predicate_map [Hash<Symbol><String||Symbol>] value either maps to a predicate in the graph or is :subject_uri indicating to use the subject uri as the value
          # @example predicate map
          #   {
          #     uri: :subject_uri,
          #     id_predicate: 'http://id.loc.gov/vocabulary/identifiers/lccn',
          #     label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
          #     altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
          #     broader_predicate:  'http://www.w3.org/2004/02/skos/core#broader',
          #     narrower_predicate: 'http://www.w3.org/2004/02/skos/core#narrower',
          #     sameas_predicate: 'http://www.w3.org/2004/02/skos/core#exactMatch'
          #   }
          # @return [Hash<Symbol><Array<Object>>] mapped result values for the term
          #    with hash of map key = array of object values for predicates identified in map parameter.
          # @example value map
          #   [
          #     {:uri=>[#<RDF::URI:0x3fcff54a829c URI:http://id.loc.gov/authorities/genreForms/gf2011026559>],
          #      :id=>[#<RDF::Literal:0x3fcff4a367b4("gf2011026559")>],
          #      :label=>[#<RDF::Literal:0x3fcff54a9a98("Science Fiction"@en)>],
          #      :altlabel=>[#<RDF::Literal:0x3fcff54a9a98("Sci-fi"@en)>],
          #      :broader=>[#<RDF::URI:0x3fcff54a8234 URI:http://id.loc.gov/authorities/genreForms/gf2014026339>],
          #      :narrower=>[#<RDF::URI:0x3fcff54a8283 URI:http://id.loc.gov/authorities/genreForms/gf2014026551>],
          #      :sameas=>[#<RDF::URI:0x3fcff54a8248 URI:http://id.loc.gov/authorities/names/n2010043281>]}
          #   ]
          def map_values(graph:, subject_uri:, prefixes: nil, ldpath_map: nil, predicate_map: nil)
            if ldpath_map.present?
              map_values_with_ldpath_map(graph: graph, ldpath_map: ldpath_map, prefixes: prefixes, subject_uri: subject_uri)
            else
              map_values_with_predicate_map(graph: graph, predicate_map: predicate_map, subject_uri: subject_uri)
            end
          end

          private

            def map_values_with_ldpath_map(graph:, ldpath_map:, prefixes:, subject_uri:)
              graph_ldpath_mapper_service.map_values(graph: graph, ldpath_map: ldpath_map, prefixes: prefixes, subject_uri: subject_uri)
            end

            def map_values_with_predicate_map(graph:, predicate_map:, subject_uri:)
              Qa.deprecation_warning(
                in_msg: 'Qa::LinkedData::Mapper::TermResultsMapperService',
                msg: 'predicate_map is deprecated; update to use ldpath_map'
              )
              graph_predicate_mapper_service.map_values(graph: graph, predicate_map: predicate_map, subject_uri: subject_uri)
            end
        end
      end
    end
  end
end
