module Qa
  class ApplicationController < ActionController::Base
    # See https://fetch.spec.whatwg.org/#http-access-control-allow-headers
    def options
      unless Qa.config.cors_headers?
        head :not_implemented
        return
      end
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
      head :no_content
    end

    private

      # See https://fetch.spec.whatwg.org/#http-access-control-allow-origin
      def cors_allow_origin_header
        response.headers['Access-Control-Allow-Origin'] = '*' if Qa.config.cors_headers?
      end
  end
end
