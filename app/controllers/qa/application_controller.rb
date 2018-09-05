module Qa
  class ApplicationController < ActionController::Base
    # Process the OPTIONS method for all routes
    # @see route definitions in /config/routes.rb
    # @note Reference: https://fetch.spec.whatwg.org/#http-access-control-allow-headers
    def options
      unless Qa.config.cors_headers?
        head :not_implemented
        return
      end
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
      head :no_content
    end

    # Add cors headers to the passed in http response if cors_headers are enabled.  Called by all controller actions
    # to adjust the response.
    # @param http response
    # @see /lib/generators/qa/install/templates/config/initializers/qa.rb
    # @note The qa.rb initializer is copied to /config/initializers/qa.rb and can be modified to enable/disable cors headers.
    # @note Reference: https://fetch.spec.whatwg.org/#http-access-control-allow-headers
    def self.cors_allow_origin_header(response)
      response.headers['Access-Control-Allow-Origin'] = '*' if Qa.config.cors_headers?
    end
  end
end
