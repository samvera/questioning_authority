# Provide attr_reader methods specific to term configuration for linked data authority configurations.  This is separated
module Qa
  module LinkedData
    module Config
      class TermConfig
        attr_reader :iri_template # [Qa::IriTemplate::Template] url template for accessing the authority (required)
        attr_reader :results_map # [Qa::LinkedData::Config::ResultsMap] map of result field to a predicate in the graph (required)
        attr_reader :subauth_map # [Qa::LinkedData::Config::SubauthMap] map of subauth values to expected values at external authority (optional)
        attr_reader :subauth_variable # [String] name of the variable in the url template that holds the subauth.  Note values for this are controlled by the subauth_map (required if subauth_map exists)
        attr_reader :default_language # [Array<String>] list of languages to include in results if language is not specified as part of the request (optional)

        # @param [Hash] config the term portion of the config
        def initialize(config)
          @supports_term_fetch = config.present?
          return unless supports_term_fetch?
          @iri_template = Qa::LinkedData::ConfigService.extract_iri_template(config: config)
          @results_map = Qa::LinkedData::ConfigService.extract_results_map(config: config, results_type: Qa::LinkedData::Config::ResultsMap::TERM_RESULTS_MAP)
          @subauth_map = Qa::LinkedData::ConfigService.extract_subauthorities_map(config: config)
          @subauth_variable = Qa::LinkedData::ConfigService.extract_subauthority_variable(config: config)
          @default_language = Qa::LinkedData::ConfigService.extract_default_language(config: config)
        end

        # Does this authority configuration have search defined?
        # @return [Boolean] true if search is configured; otherwise, false
        def supports_term_fetch?
          @supports_term_fetch
        end
        alias supports_term? supports_term_fetch?
      end
    end
  end
end
