# frozen_string_literal: true
module Qa::Authorities
  class Getty::AAT < Base
    include WebServiceBase

    def search(q)
      parse_authority_response(json(build_query_url(q)))
    end

    def build_query_url(q)
      "http://vocab.getty.edu/sparql.json?query=#{ERB::Util.url_encode(sparql(q))}&_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"
    end

    def sparql(q) # rubocop:disable Metrics/MethodLength
      search = untaint(q)
      if search.include?(' ')
        clauses = search.split(' ').collect do |i|
          %((regex(?name, "#{i}", "i")))
        end
        ex = "(#{clauses.join(' && ')})"
      else
        ex = %(regex(?name, "#{search}", "i"))
      end
      # The full text index matches on fields besides the term, so we filter to ensure the match is in the term.
      %(SELECT ?s ?name {
              ?s a skos:Concept; luc:term "#{search}";
                 skos:inScheme <http://vocab.getty.edu/aat/> ;
                 gvp:prefLabelGVP [skosxl:literalForm ?name].
              FILTER #{ex} .
            } ORDER BY ?name).gsub(/[\s\n]+/, " ")
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find(id)
      json(find_url(id))
    end

    def find_url(id)
      "http://vocab.getty.edu/download/json?uri=http://vocab.getty.edu/aat/#{id}.json"
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
    rescue StandardError => e
      cause = response.fetch('error', {}).fetch('cause', 'UNKNOWN')
      cause = cause.presence || 'UNKNOWN'
      Rails.logger.warn "  ERROR fetching Getty response: #{e.message}; cause: #{cause}"
      {}
    end
  end
end
