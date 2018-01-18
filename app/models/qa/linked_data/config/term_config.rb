# Provide attr_reader methods specific to term configuration for linked data authority configurations.  This is separated
module Qa
  module LinkedData
    module Config
      class TermConfig < Qa::LinkedData::Config::ActionConfig
        # @param [Hash] config the action specific portion of the config
        def initialize(config)
          super
          return unless supports_term_fetch?
          @action_request_variable = Qa::LinkedData::ConfigService.extract_termid_variable(config: config)
          @results_map = Qa::LinkedData::ConfigService.extract_results_map(config: config, results_type: Qa::LinkedData::ConfigService::TERM_RESULTS_MAP)
        end

        # Does this authority configuration have term defined?
        # @return [Boolean] true if term is configured; otherwise, false
        def supports_term_fetch?
          @supports_action
        end
        alias supports_term? supports_term_fetch?
      end
    end
  end
end
