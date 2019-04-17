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

    # Provide a token that allows reloading of linked data authorities through the controller
    # action '/reload/linked_data/authorities?auth_token=YOUR_AUTH_TOKEN_DEFINED_HERE' without
    # requiring a restart of rails. By default, reloading through the browser is not allowed
    # when the token is nil or blank.  Change to your approved token string in
    # config/initializers/qa.rb.
    attr_writer :authorized_reload_token
    def authorized_reload_token
      @authorized_reload_token ||= nil
    end

    def valid_authority_reload_token?(token)
      return false if token.blank? || authorized_reload_token.blank?
      token == authorized_reload_token
    end

    # Hold linked data authority configs
    attr_accessor :linked_data_authority_configs

    # For linked data access, specify default language for sorting and selection.  The default is only used if a language is not
    # specified in the authority's configuration file and not passed in as a parameter.  (e.g. :en, [:en], or [:en, :fr])
    attr_writer :default_language
    def default_language
      @default_language ||= :en
    end

    # When true, prevents ldpath requests from making additional network calls.  All values will come from the context graph
    # passed to the ldpath request.
    attr_writer :limit_ldpath_to_context
    def limit_ldpath_to_context?
      return true if @limit_ldpath_to_context.nil?
      @limit_ldpath_to_context
    end
  end
end
