require 'uri'

module Authorities
  class Lcsh < Authorities::Base

    # Initialze the Lcsh class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize(q, sub_authority='')
      self.query_url= "http://id.loc.gov/authorities/suggest/?q=" + q

      super
    end

    # We're only interested in the list of suggestions. Set this to .repsonse
    # so the controller can do the rest. 
    def parse_authority_response
      self.response = self.suggestions
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

    def get_id_from_url url
      uri = URI(url)
      return uri.path.split(/\//).last
    end


    # TODO: there's other info in the self.response that might be worth making access to, such as
    # RDF links, etc.

  end
end