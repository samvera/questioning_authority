module Qa::Authorities
  class Getty::TGN < Base
    include WebServiceBase

    def search(q)
      parse_authority_response(json(build_query_url(q)))
    end

    def build_query_url(q)
      query = URI.escape(sparql(untaint(q)))
      # Replace ampersands, otherwise the query will fail
      # Gsub hack to convert the encoded regex in the REPLACE into a form Getty understands
      "http://vocab.getty.edu/sparql.json?query=#{query.gsub('&', '%26').gsub(',[%5E,]+,[%5E,]+$', '%2C[^%2C]%2B%2C[^%2C]%2B%24')}&_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"
    end

    # Use a regex to exclude the continent and 'world' from the query
    # If only one word is entered only search the name (not the parent string)
    # If more than one word is entered, one word must appear in the name, and all words in either parent or name
    def sparql(q)
      search = untaint(q)
      if search.include?(' ')
        ex = "(("
        search.split(' ').each do |i|
          ex += "regex(CONCAT(?name, ', ', REPLACE(str(?par), \",[^,]+,[^,]+$\", \"\")), \"#{i}\",\"i\" ) && "
        end
        ex = ex[0..ex.length - 4]
        ex += ') && ('
        search.split(' ').each do |i|
          ex += "regex(?name, \"#{i}\",\"i\" ) || "
        end
        ex = ex[0..ex.length - 4]
        ex += ") )"

      else
        ex = "regex(?name, \"#{search}\", \"i\")"
      end

      # The full text index matches on fields besides the term, so we filter to ensure the match is in the term.
      sparql = "SELECT DISTINCT ?s ?name ?par {
              ?s a skos:Concept; luc:term \"#{search}\";
                 skos:inScheme <http://vocab.getty.edu/tgn/> ;
                 gvp:prefLabelGVP [skosxl:literalForm ?name] ;
                  gvp:parentString ?par .
              FILTER #{ex} .
            } ORDER BY ?name ASC(?par)"
      sparql
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find(id)
      json(find_url(id))
    end

    def find_url(id)
      "http://vocab.getty.edu/tgn/#{id}.json"
    end

    def request_options
      { accept: 'application/sparql-results+json' }
    end

    private

      # Reformats the data received from the service
      # Adds the parentString, minus the contintent and 'World' for disambiguation
      def parse_authority_response(response)
        response['results']['bindings'].map do |result|
          { 'id' => result['s']['value'], 'label' => result['name']['value'] + ' (' + result['par']['value'].gsub(/\,[^\,]+\,[^\,]+$/, '') + ')' }
        end
      end
  end
end
