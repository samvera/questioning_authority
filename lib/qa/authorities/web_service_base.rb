require 'rest_client'

module Qa::Authorities
  class WebServiceBase < Base
    attr_accessor :raw_response

    # mix-in to retreive and parse JSON content from the web
    def get_json(url)
      r = RestClient.get url, request_options
      JSON.parse(r)
    end

    def request_options
      { accept: :json }
    end
  end
end
