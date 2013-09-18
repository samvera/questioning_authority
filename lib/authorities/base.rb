require 'curl'

module Authorities
  class Base
    attr_accessor :response, :query_url, :raw_response

    def initialize(q, sub_authority='')
      # Implement Me and set self.query_url

      if self.query_url == nil
        raise Exception 'query url in your authorities lib is not set (implement in initialize)'
      end

      #Default implementation assumed query_url is set
      http = Curl.get(self.query_url) do |http|
        http.headers['Accept'] = 'application/json'
      end

      self.raw_response = JSON.parse(http.body_str)
    end

    def self.authority_valid?(sub_authority)
      sub_authority == nil || sub_authorities.include?(sub_authority)
    end

    def self.sub_authorities
      [] #Overwrite if you have sub_authorities
    end

    def parse_authority_response
      # Overwrite me unless your raw response needs no parsing
      self.response = self.raw_response

    end

    def get_full_record(id)
      # implement me
      {"id"=>id}.to_json
    end

    # Parse the result from LOC, and return an JSON array of terms that match the query.
    def results
      self.response.to_json
    end

    # TODO: there's other info in the self.response that might be worth making access to, such as
    # RDF links, etc.

  end
end
