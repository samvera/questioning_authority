require 'curl'

module Authorities
  class Base
    attr_accessor :response, :query_url, :raw_response

    def initialize(q, sub_authority='')
      # Implement Me and set self.query_url

      #Default implementation assumed query_url is set
      http = Curl.get(self.query_url) do |http|
        http.headers['Accept'] = 'application/json'
      end

      self.raw_response = JSON.parse(http.body_str)
    end

    def valid?(sub_authority)
      sub_authority == nil || sub_authorities.include?(sub_authority)
    end

    def sub_authorities
      [] #Overwrite if different
    end

    def parse_authority_response


      # Extend me using raw_response = super() or completely overwrite
    end

    def get_full_record(id)
      # implement me
      [{"id"=>id}]
    end

    # Parse the result from LOC, and return an JSON array of terms that match the query.
    def results
      self.response.to_json
    end

    # TODO: there's other info in the self.response that might be worth making access to, such as
    # RDF links, etc.

  end
end
