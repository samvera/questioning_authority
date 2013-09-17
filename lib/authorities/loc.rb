require 'curl'

module Authorities
  class Loc

    attr_accessor :response

    # Initialze the Lcsh class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize q
      http = Curl.get(
          "http://id.loc.gov/authorities/suggest/?q=" + q
      ) do |http|
        http.headers['Accept'] = 'application/json'
      end
      self.response = JSON.parse(http.body_str)
    end

    # Parse the result from LOC, and return an JSON array of terms that match the query.
    def results
      self.response[1].to_json
    end

    # TODO: there's other info in the self.response that might be worth making access to, such as
    # RDF links, etc.

  end
end