# Provide services that are common across configurations for search and term.
module Qa
  module LinkedData
    class ConfigService
      DEFAULT_SUBAUTH_VARIABLE = 'subauth'.freeze
      DEFAULT_TERMID_VARIABLE = 'term_id'.freeze
      DEFAULT_QUERY_VARIABLE = 'query'.freeze
      TERM_RESULTS_MAP = :term
      SEARCH_RESULTS_MAP = :search

      # Extract the iri template from the config
      # @param config [Hash] configuration (json) holding the iri template to be extracted
      # @param var [Symbol] key identifying the iri template in the configuration
      # @return [Qa::IriTemplate::UrlConfig] url template for accessing the authority
      def self.extract_iri_template(config:, var: :url)
        template_config = config.fetch(var, nil)
        raise Qa::InvalidConfiguration, "iri template is required" unless template_config
        Qa::IriTemplate::UrlConfig.new(template_config)
      end

      # Extract the results map from the config
      # @param config [Hash] configuration (json) holding the results map to be extracted
      # @param var [Symbol] key identifying the results map in the configuration
      # @param results_type [Symbol] Qa::LinkedData::ConfigService::TERM_RESULTS_MAP || Qa::LinkedData::ConfigService::SEARCH_RESULTS_MAP
      # @return [Qa::LinkedData::ResultsMap] map of result field to a predicate in the graph
      def self.extract_results_map(config:, var: :results, results_type: nil)
        raise ArgumentError, "Unsupported results_type #{results_type}" unless [TERM_RESULTS_MAP, SEARCH_RESULTS_MAP].include?(results_type)
        results_config = config.fetch(var, nil)
        raise Qa::InvalidConfiguration, "Results map is required" unless results_config
        results_map = Qa::LinkedData::Config::SearchResultsMap.new(results_config) if results_type == SEARCH_RESULTS_MAP
        results_map = Qa::LinkedData::Config::TermResultsMap.new(results_config) if results_type == TERM_RESULTS_MAP
        results_map
      end

      # Extract the subauthorities map from the config
      # @param config [Hash] configuration (json) holding the subauthorities map to be extracted
      # @param var [Symbol] key identifying the subauthorities map in the configuration
      # @return [Qa::LinkedData::SubauthMap] map of qa subauthority names to expected values at external authority
      def self.extract_subauthorities_map(config:, var: :subauthorities)
        subauth_config = config.fetch(var, nil)
        return nil unless subauth_config
        Qa::LinkedData::Config::SubauthMap.new(subauth_config)
      end

      # Extract the subauthority substitution variable from the config
      # @param config [Hash] configuration (json) holding the subauthority variable name to be extracted
      # @param var [Symbol] key identifying the subauthority variable in the configuration
      # @return [String] name of the variable in the url template that holds the subauth.  Note values for this are controlled by the subauth_map (default='subauth')
      def self.extract_subauthority_variable(config:, var: :subauth)
        rep_patterns = config.fetch(:qa_replacement_patterns, nil)
        return DEFAULT_SUBAUTH_VARIABLE unless rep_patterns.present?
        rep_patterns.fetch(var, DEFAULT_SUBAUTH_VARIABLE)
      end

      # Extract the term id substitution variable from the config
      # @param config [Hash] configuration (json) holding the term id variable name to be extracted
      # @param var [Symbol] key identifying the term id variable in the configuration
      # @return [String] name of the variable in the url template that holds the term id.
      def self.extract_termid_variable(config:, var: :term_id)
        rep_patterns = config.fetch(:qa_replacement_patterns, nil)
        return DEFAULT_TERMID_VARIABLE unless rep_patterns.present?
        rep_patterns.fetch(var, DEFAULT_TERMID_VARIABLE)
      end

      # Extract the query substitution variable from the config
      # @param config [Hash] configuration (json) holding the query variable name to be extracted
      # @param var [Symbol] key identifying the query variable in the configuration
      # @return [String] name of the variable in the url template that holds the query.
      def self.extract_query_variable(config:, var: :query)
        rep_patterns = config.fetch(:qa_replacement_patterns, nil)
        return DEFAULT_QUERY_VARIABLE unless rep_patterns.present?
        rep_patterns.fetch(var, DEFAULT_QUERY_VARIABLE)
      end

      # Extract the context map from the config
      # @param config [Hash] configuration (json) holding the context map to be extracted
      # @param var [Symbol] key identifying the context map in the configuration
      # @return [Qa::LinkedData::ContextMap] map of extended result fields to predicates in the graph
      def self.extract_context_map(config:, var: :context)
        context_config = config.fetch(var, nil)
        return nil unless context_config
        Qa::LinkedData::Config::ContextMap.new(context_config)
      end

      # Extract the default language from the config
      # @param config [Hash] configuration (json) holding the default language to be extracted
      # @param var [Symbol] key identifying the default language in the configuration
      # @return [Array<String>] one or more language codes (e.g. 'en', 'fr', 'de', etc.); or nil if none specified
      def self.extract_default_language(config:, var: :language)
        language = config.fetch(var, nil)
        return nil unless language.present?
        return [language] if language.is_a? String
        return language if language.is_a? Array
        nil # TODO: can we get the locale of the current_user and use that as the default?
      end
    end
  end
end
