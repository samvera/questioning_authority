require 'curl'

module Authorities
  class Base
    attr_accessor :response, :query_url

    def initialize(q, sub_authority='')
      # Implement Me

      #self.response = parse_authority_response(raw)
    end

    def valid?(sub_authority)
      sub_authority == nil || sub_authorities.include?(sub_authority)
    end

    def sub_authorities
      [] #Overwrite if different
    end

    def parse_authority_response
      Curl.get(self.query_url) do |http|
        http.headers['Accept'] = 'application/json'
      end

      JSON.parse(http.body_str)
    end

    def get_full_record(id)
      # implement me
    end

    # Parse the result from LOC, and return an JSON array of terms that match the query.
    def results
      self.response.to_json
    end

    # TODO: there's other info in the self.response that might be worth making access to, such as
    # RDF links, etc.

  end
end
