require 'faraday'

module Qa::Authorities
  module WebServiceBase
    attr_accessor :raw_response

    # mix-in to retreive and parse JSON content from the web
    def get_json(url)
      r = response(url).body
      JSON.parse(r)
    end

    def response(url)
      Faraday.get(url) do |req|
        req.headers['Accept'] = 'application/json'
        req.options.params_encoder = Faraday::FlatParamsEncoder
      end
    end
  end
end
