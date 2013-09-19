require 'uri'

module Authorities
  class Lcsh < Authorities::Base

    # Initialze the Lcsh class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize(q, sub_authority='')
      self.query_url= "http://id.loc.gov/authorities/suggest/?q=" + q

      super
    end

    # Format response to the correct JSON structure
    def parse_authority_response
      self.response = build_response
    end

    def query
      self.raw_response[0]
    end

    def suggestions
      self.raw_response[1]
    end

    def urls_for_suggestions
      self.raw_response[3]
    end

    private

    def build_response a = Array.new
      self.suggestions.each_index do |i|
        a << {"id"=>get_id_from_url(urls_for_suggestions[i]), "label"=>suggestions[i]}
      end
      return a
    end

    def get_id_from_url url
      uri = URI(url)
      return uri.path.split(/\//).last
    end

  end
end