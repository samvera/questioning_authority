module Qa::Authorities
  class Getty::Ulan < Base
    include WebServiceBase

    def search(q)
      parse_authority_response(json(build_query_url(q)))
    end

    # Replace ampersands, otherwise the query will fail
    def build_query_url(q)
      "http://vocab.getty.edu/sparql.json?query=#{URI.escape(sparql(q)).gsub('&', '%26')}&_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"
    end

    def sparql(q)
      search = untaint(q)
      # if more than one term is supplied, check both preferred and alt labels
      if search.include?(' ')
        ex = "("
        search.split(' ').each do |i|
          ex += "regex(CONCAT(?name, ' ', ?alt), \"#{i}\",\"i\" ) && "
        end
        ex = ex[0..ex.length - 4]
        ex += ")"
      else
        ex = "regex(?name, \"#{search}\", \"i\")"
      end
      # The full text index matches on fields besides the term, so we filter to ensure the match is in the term.
      sparql = "SELECT DISTINCT ?s ?name ?bio {
              ?s a skos:Concept; luc:term \"#{search}\";
                 skos:inScheme <http://vocab.getty.edu/ulan/> ;
                 gvp:prefLabelGVP [skosxl:literalForm ?name] ;
                 foaf:focus/gvp:biographyPreferred [schema:description ?bio] ;
                 skos:altLabel ?alt .
              FILTER #{ex} .
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
      "http://vocab.getty.edu/ulan/#{id}.json"
    end

    def request_options
      { accept: 'application/sparql-results+json' }
    end

    private

      # Reformats the data received from the Getty service
      # Add the bio for disambiguation
      def parse_authority_response(response)
        response['results']['bindings'].map do |result|
          { 'id' => result['s']['value'], 'label' => result['name']['value'] + ' (' + result['bio']['value'] + ')' }
        end
      end
  end
end
