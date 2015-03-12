require 'rest_client'

module Qa::Authorities
  class WebServiceBase < Base
    attr_accessor :raw_response

    # mix-in to retreive and parse JSON content from the web
    def get_json(url)
      r = RestClient.get url, {accept: :json}
      JSON.parse(r)
    end
  end
end
