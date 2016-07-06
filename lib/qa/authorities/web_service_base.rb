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
      uri = URI(url)
      conn = Faraday.new uri.scheme+"://"+uri.host
      conn.options.params_encoder = Faraday::FlatParamsEncoder
      conn.get do |req|
        req.headers['Accept'] = 'application/json'        
        req.url 'search/', :format => "json"
        req.params = Rack::Utils.parse_query(uri.query)
      end

    end
  end
end
