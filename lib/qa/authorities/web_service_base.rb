require 'faraday'

module Qa::Authorities
  ##
  # Mix-in to retreive and parse JSON content from the web with Faraday.
  module WebServiceBase
    ##
    # @!attribute [rw] raw_response
    attr_accessor :raw_response

    ##
    # Make a web request & retieve a JSON response for a given URL.
    #
    # @param url [String]
    # @return [Hash] a parsed JSON response
    def json(url)
      r = response(url).body
      JSON.parse(r)
    end

    ##
    # @deprecated Use #json instead
    def get_json(url)
      warn '[DEPRECATED] #get_json is deprecated; use #json instead.' \
           "Called from #{Gem.location_of_caller.join(':')}."
      json(url)
    end

    ##
    # Make a web request and retrieve the response.
    #
    # @param url [String]
    # @return [Faraday::Response]
    def response(url)
      Faraday.get(url) { |req| req.headers['Accept'] = 'application/json' }
    end
  end
end
