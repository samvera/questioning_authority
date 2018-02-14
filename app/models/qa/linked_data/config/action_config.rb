# Provide attr_reader methods specific to all action configurations for linked data authority configurations.
module Qa
  module LinkedData
    module Config
      class ActionConfig # ABSTRACT CLASS
        attr_reader :url_config # [Qa::IriTemplate::UrlConfig] iri template configuration for accessing the authority (required)
        attr_reader :results_map # [Qa::LinkedData::Config::ResultsMap] map of result field to a predicate in the graph (required)
        attr_reader :subauth_map # [Qa::LinkedData::Config::SubauthMap] map of subauth values to expected values at external authority (optional)
        attr_reader :subauth_variable # [String] name of the variable in the url template that holds the subauth.  Note values for this are controlled by the subauth_map (required if subauth_map exists)
        attr_reader :action_request_variable # [String] name of the variable in the url template that holds the request specific to the type of action.  Defined in concrete action classes.
        attr_reader :default_language # [Array<String>] list of languages to include in results if language is not specified as part of the request (optional)

        # @param [Hash] config the action specific portion of the config
        def initialize(config)
          @supports_action = config.present?
          return unless supports_action?
          @url_config = Qa::LinkedData::ConfigService.extract_iri_template(config: config)
          @subauth_map = Qa::LinkedData::ConfigService.extract_subauthorities_map(config: config)
          @subauth_variable = Qa::LinkedData::ConfigService.extract_subauthority_variable(config: config)
          @default_language = Qa::LinkedData::ConfigService.extract_default_language(config: config)
        end

        # Does this authority configuration have the specified action defined?  TODO: Don't think this is needed.  Defined in concrete classes.
        # @return [Boolean] true if search is configured; otherwise, false
        def supports_action?
          @supports_action
        end

        # Does this action configuration support the specified subauthority?
        # @return [Boolean] true if search is configured; otherwise, false
        def supports_subauthority?(subauthority)
          return false if subauth_variable.blank?
          subauth_map.valid?(subauthority)
        end

        # Is this a search configuration?
        # @returns ABSTRACT always returns false.  Override in search_config and return true.
        def search?
          false
        end

        # Is this a term configuration?
        # @returns ABSTRACT always returns false.  Override in term_config and return true.
        def term?
          false
        end
      end
    end
  end
end
