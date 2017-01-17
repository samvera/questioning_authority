module Qa::Authorities
  class Getty::AAT < Base
    include WebServiceBase

    def search(q)
      parse_authority_response(json(build_query_url(q)))
    end

    def build_query_url(q)
      "http://vocab.getty.edu/sparql.json?query=#{URI.escape(sparql(q))}&_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"
    end

    def sparql(q)
      search = untaint(q)
      # The full text index matches on fields besides the term, so we filter to ensure the match is in the term.
      sparql = "SELECT ?s ?name {
              ?s a skos:Concept; luc:term \"#{search}\";
                 skos:inScheme <http://vocab.getty.edu/aat/> ;
                 gvp:prefLabelGVP [skosxl:literalForm ?name].
              FILTER regex(?name, \"#{search}\", \"i\") .
            } ORDER BY ?name"
      sparql
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find(id)
      json(find_url(id))
    end

    def find_url(id)
      "http://vocab.getty.edu/aat/#{id}.json"
    end

    def request_options
      { accept: 'application/sparql-results+json' }
    end

    private

      # Reformats the data received from the Getty service
      def parse_authority_response(response)
        response['results']['bindings'].map do |result|
          { 'id' => result['s']['value'], 'label' => result['name']['value'] }
        end
      end
  end
end
