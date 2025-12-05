# Provide service for mapping predicates to object values.
module Qa
  module LinkedData
    module Mapper
      class GraphMapperService
        # Extract predicates specified in the predicate_map from the graph and return as a value map for a single subject URI.
        # @param graph [RDF::Graph] the graph from which to extract result values
        # @param predicate_map [Hash<Symbol><String||Symbol>] value either maps to a predicate in the graph or is :subject_uri indicating to use the subject uri as the value
        # @example predicate_map
        #   {
        #     uri: :subject_uri,
        #     id: [#<RDF::URI URI:http://id.loc.gov/vocabulary/identifiers/lccn>],
        #     label: [#<RDF::URI URI:http://www.w3.org/2004/02/skos/core#prefLabel>],
        #     altlabel: [#<RDF::URI URI:http://www.w3.org/2004/02/skos/core#altLabel>],
        #     sort: [#<RDF::URI URI:http://vivoweb.org/ontology/core#rank>]'
        #   }
        # @param subject_uri [RDF::URI] the subject within the graph for which the values are being extracted
        # @return [<Hash<Symbol><Array<Object>>] mapped result values with hash of map key = array of object values for predicates identified in predicate_map.
        # @example value map for a single result
        #   {:uri=>[#<RDF::URI:0x3fcff54a829c URI:http://id.loc.gov/authorities/names/n2010043281>],
        #    :id=>[#<RDF::Literal:0x3fcff4a367b4("n2010043281")>],
        #    :label=>[#<RDF::Literal:0x3fcff54a9a98("Valli, Sabrina"@en)>],
        #    :altlabel=>[],
        #    :sort=>[#<RDF::Literal:0x3fcff54b4c18("2")>]}
        def self.map_values(graph:, predicate_map:, subject_uri:, &block)
          Deprecation.warn('`Qa::LinkedData::Mapper::GraphMapperService` is deprecated; update to `Qa::LinkedData::Mapper::GraphPredicateMapperService`.')
          Qa::LinkedData::Mapper::GraphPredicateMapperService.map_values(graph: graph, predicate_map: predicate_map, subject_uri: subject_uri, &block)
        end
      end
    end
  end
end
