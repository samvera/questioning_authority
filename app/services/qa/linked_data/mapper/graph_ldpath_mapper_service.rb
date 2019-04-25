# Provide service for mapping predicates to object values.
module Qa
  module LinkedData
    module Mapper
      class GraphLdpathMapperService
        class_attribute :ldpath_service
        self.ldpath_service = Qa::LinkedData::LdpathService

        # Extract values for ldpath specified in the ldpath_map from the graph and return as a value map for a single subject URI.
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
        # @param subject_uri [RDF::URI] the subject within the graph for which the values are being extracted
        # @return [<Hash<Symbol><Array<Object>>] mapped result values with hash of map key = array of object values identified by the ldpath map.
        # @example value map for a single result
        #   {:uri=>[#<RDF::URI:0x3fcff54a829c URI:http://id.loc.gov/authorities/names/n2010043281>],
        #    :id=>[#<RDF::Literal:0x3fcff4a367b4("n2010043281")>],
        #    :label=>[#<RDF::Literal:0x3fcff54a9a98("Valli, Sabrina"@en)>],
        #    :altlabel=>[],
        #    :sort=>[#<RDF::Literal:0x3fcff54b4c18("2")>]}
        def self.map_values(graph:, ldpath_map:, subject_uri:, prefixes: {})
          value_map = {}
          ldpath_map.each do |key, ldpath|
            next value_map[key] = [subject_uri] if ldpath == :subject_uri
            ldpath_program = ldpath_service.ldpath_program(ldpath: ldpath, prefixes: prefixes)
            values = ldpath_service.ldpath_evaluate(program: ldpath_program, graph: graph, subject_uri: subject_uri)
            value_map[key] = values
          end
          value_map = yield value_map if block_given?
          value_map
        end
      end
    end
  end
end
