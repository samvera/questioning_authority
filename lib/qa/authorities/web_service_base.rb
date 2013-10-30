require 'curl'
require 'rest_client'

module Qa::Authorities
  class WebServiceBase
    attr_accessor :response, :raw_response

    # mix-in to retreive and parse JSON content from the web
    def get_json(url)
      r = RestClient.get url, {accept: :json}
      self.response = JSON.parse(r)
    end

    # This method should be removed
    # use #response instead
    def results
      self.response
    end
  end
end
