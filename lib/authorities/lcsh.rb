require 'curl'

module Authorities
  class Lcsh < Authorities::Base

    # Initialze the Lcsh class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize(q, sub_authority='')
      self.query_url= "http://id.loc.gov/authorities/suggest/?q=" + q
    end

    def parse_authority_response
      raw_response = super()
      raw_response[1]
    end



    # TODO: there's other info in the self.response that might be worth making access to, such as
    # RDF links, etc.

  end
end