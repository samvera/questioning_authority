# Provide attr_reader methods specific to search configuration for linked data authority configurations.
module Qa
  module LinkedData
    module Config
      class SearchConfig < Qa::LinkedData::Config::ActionConfig
        attr_reader :context_map # [Qa::LinkedData::Config::ContextMap] map of external authority predicates to json structure (optional)

        # @param [Hash] config the search portion of the config
        def initialize(config)
          super
          return unless supports_search_query?
          @action_request_variable = Qa::LinkedData::ConfigService.extract_query_variable(config: config)
          @results_map = Qa::LinkedData::ConfigService.extract_results_map(config: config, results_type: Qa::LinkedData::ConfigService::SEARCH_RESULTS_MAP)
          @context_map = Qa::LinkedData::ConfigService.extract_context_map(config: config)
        end

        # Does this authority configuration have search defined?
        # @return [Boolean] true if search is configured; otherwise, false
        def supports_search_query?
          @supports_action
        end
        alias supports_search? supports_search_query?
      end
    end
  end
end
