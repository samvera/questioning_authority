module Qa
  class Configuration
    def cors_headers?
      return @cors_headers_enabled unless @cors_headers_enabled.nil?
      @cors_headers_enabled = false
    end

    def enable_cors_headers
      @cors_headers_enabled = true
    end

    def disable_cors_headers
      @cors_headers_enabled = false
    end
  end
end
