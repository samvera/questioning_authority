# Provide service for mapping graph to json limited to configured fields and context.
module Qa
  module LinkedData
    module Mapper
      class SearchResultsMapperService
        class << self
          # class_attribute :graph_mapper_service
          # graph_mapper_service = QA::LinkedData::Mapper::GraphMapperService

          # Extract predicates specified in the predicate_map from the graph and return as an array of value maps for each search result subject URI.
          # If a sort key is present, a subject will only be included in the results if it has a statement with the sort predicate.
          # @param graph [RDF::Graph] the graph from which to extract result values
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
          # @return [Array<Hash<Symbol><Array<Object>>>] mapped result values with each result as an element in the array
          #    with hash of map key = array of object values for predicates identified in map parameter.
          # @example value map for a single result
          #   [
          #     {:uri=>[#<RDF::URI:0x3fcff54a829c URI:http://id.loc.gov/authorities/names/n2010043281>],
          #      :id=>[#<RDF::Literal:0x3fcff4a367b4("n 2010043281")>],
          #      :label=>[#<RDF::Literal:0x3fcff54a9a98("Valli, Sabrina"@en)>],
          #      :altlabel=>[],
          #      :sort=>[#<RDF::Literal:0x3fcff54b4c18("2")>]}
          #   ]
          def map_values(graph:, predicate_map:, sort_key:, preferred_language: nil)
            search_matches = []
            graph.subjects.each do |subject|
              next if subject.anonymous? # skip blank nodes
              values = Qa::LinkedData::Mapper::GraphMapperService.map_values(graph: graph, predicate_map: predicate_map, subject_uri: subject)
              search_matches << values unless sort_key.present? && values[sort_key].blank?
            end
            search_matches = Qa::LinkedData::DeepSortService.new(search_matches, sort_key, preferred_language).sort
            search_matches
          end
        end
      end
    end
  end
end
