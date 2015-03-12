require 'uri'

module Qa::Authorities
  class Getty < WebServiceBase

    def initialize *args
      super
      @sub_authority ||= args.first
      raise "No sub-authority provided" if sub_authority.nil?
    end

    def sub_authorities
      [ "aat" ]
    end

    def search q
      parse_authority_response(json(build_query_url(q)))
    end

    # get_json is not ideomatic, so we'll make an alias
    def json(*args)
      get_json(*args)
    end

    def build_query_url q
      untainted = q.gsub(/[\w\s-]/, '')
      sparql = "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
                SELECT * WHERE { ?s skos:prefLabel ?name .
                  ?s skos:inScheme <http://vocab.getty.edu/#{@sub_authority}/> .
                  ?s rdf:type <http://vocab.getty.edu/ontology#Concept> .
                  FILTER regex(?name, \"#{untainted}\", \"i\") .
                  FILTER langMatches( lang(?name), \"EN\" ) .
                } LIMIT 10"
      "http://vocab.getty.edu/sparql.json?query=#{URI.escape(sparql)}&_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"
    end

    def find id
      json(find_url(id))
    end

    def find_url id
      "http://vocab.getty.edu/#{@sub_authority}/#{id}.json"
    end

    def request_options
      # Don't pass a request header. See http://answers.semanticweb.com/questions/31906/getty-sparql-gives-a-404-if-you-pass-accept-applicationjson
      { }
    end

    private

    # Reformats the data received from the LOC service
    def parse_authority_response(response)
      response['results']['bindings'].map do |result|
        { 'id' => result['s']['value'], 'label' => result['name']['value'] }
      end
    end

  end
end

