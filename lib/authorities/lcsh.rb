require 'curl'
require 'uri'

module Authorities
  class Lcsh

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

    def query
      self.response[0]
    end

    def suggestions
      self.response[1]
    end

    def urls_for_suggestions
      self.response[3]
    end

    # Parse the result and assemble array of ids, terms and urls
    def results terms = Array.new
      self.suggestions.each_index do |i|
        terms << {:id => get_id_from_url(urls_for_suggestions[i]), :label => suggestions[i]}
      end
      return terms
    end

    private

    def get_id_from_url url
      uri = URI(url)
      return uri.path.split(/\//).last
    end

  end
end