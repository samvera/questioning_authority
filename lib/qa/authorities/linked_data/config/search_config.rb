# Provide attr_reader methods specific to search configuration for linked data authority configurations.  This is separated
# out for readability and file length.
# @see Qa::Authorities::LinkedData::Config
# @see Qa::Authorities::LinkedData::TermConfig
module Qa::Authorities
  module LinkedData
    module SearchConfig
      # Return the full configuration for search query
      # @return [String] the search configuration
      def search_config
        cfg = config_value(authority_config, :search)
        cfg = nil if cfg.is_a?(Hash) && cfg.empty?
        cfg
      end

      # Does this authority configuration have search defined?
      # @return [True|False] true if search is configured; otherwise, false
      def supports_search?
        !search_config.nil?
      end

      # Return search url encoding defined in the configuration for this authority.
      # @return [Hash] the configured search url
      def search_url
        config_value(search_config, :url)
      end

      # Return search url template defined in the configuration for this authority.
      # @return [String] the configured search url template
      def search_url_template
        config_value(search_url, :template)
      end

      # Return search url parameter mapping defined in the configuration for this authority.
      # @return [Hash] the configured search url parameter mappings with variable name as key
      def search_url_mappings
        return @search_url_mappings unless @search_url_mappings.nil?
        mappings = config_value(search_url, :mapping)
        return {} if mappings.nil?
        Hash[*mappings.collect { |m| [m[:variable].to_sym, m] }.flatten]
      end

      # Return the preferred language for literal value selection for search query.  Only applies if the authority provides language encoded literals.
      # @return [String] the configured language for search query
      def search_language
        return @search_language unless @search_language.nil?
        lang = config_value(search_config, :language)
        return nil if lang.nil?
        lang = [lang] if lang.is_a? String
        @search_language = lang.collect(&:to_sym)
      end

      # Return results predicates
      # @return [Hash] all the configured predicates to pull out of the results
      def search_results
        config_value(search_config, :results)
      end

      # Return results id_predicate
      # @return [String] the configured predicate to use to extract the id from the results
      def search_results_id_predicate
        predicate_uri(search_results, :id_predicate)
      end

      # Return results label_predicate
      # @return [String] the configured predicate to use to extract label values from the results
      def search_results_label_predicate
        predicate_uri(search_results, :label_predicate)
      end

      # Return results altlabel_predicate
      # @return [String] the configured predicate to use to extract altlabel values from the results
      def search_results_altlabel_predicate
        predicate_uri(search_results, :altlabel_predicate)
      end

      # Does this authority configuration support sorting of search results?
      # @return [True|False] true if sorting of search results is supported; otherwise, false
      def search_supports_sort?
        return true unless search_results_sort_predicate.nil? || !search_results_sort_predicate.size.positive?
        false
      end

      # Return results sort_predicate
      # @return [String] the configured predicate to use for sorting results from the query search
      def search_results_sort_predicate
        predicate_uri(search_results, :sort_predicate)
      end

      # Return parameters that are required for QA api
      # @return [Hash] the configured search url parameter mappings
      def search_qa_replacement_patterns
        config_value(search_config, :qa_replacement_patterns)
      end

      # Are there replacement parameters configured for search query?
      # @return [True|False] true if there are replacement parameters configured for search query; otherwise, false
      def search_replacements?
        search_replacement_count.positive?
      end

      # Return the number of possible replacement values to make in the search URL
      # @return [Integer] the configured number of possible replacements in the search url
      def search_replacement_count
        search_replacements.size
      end

      # Return the replacement configurations
      # @return [Hash] the configurations for search url replacements
      def search_replacements
        return @search_replacements unless @search_replacements.nil?
        @search_replacements = {}
        @search_replacements = search_url_mappings.select { |k, _v| !search_qa_replacement_patterns.include?(k) } unless search_config.nil? || search_url_mappings.nil?
        @search_replacements
      end

      # Are there subauthorities configured for search query?
      # @return [True|False] true if there are subauthorities configured for search query; otherwise, false
      def search_subauthorities?
        search_subauthority_count.positive?
      end

      # Is a specific subauthority configured for search query?
      # @return [True|False] true if the specified subauthority is configured for search query; otherwise, false
      def search_subauthority?(subauth_name)
        subauth_name = subauth_name.to_sym if subauth_name.is_a? String
        search_subauthorities.key? subauth_name
      end

      # Return the number of subauthorities defined for search query
      # @return [Integer] the number of subauthorities defined for search query
      def search_subauthority_count
        search_subauthorities.size
      end

      # Return the list of subauthorities for search query
      # @return [Hash] the configurations for search url replacements
      def search_subauthorities
        @search_subauthorities ||= {} if search_config.nil? || !(search_config.key? :subauthorities)
        @search_subauthorities ||= config_value(search_config, :subauthorities)
      end

      # Return the replacement configurations
      # @return [Hash] the configurations for search url replacements
      def search_subauthority_replacement_pattern
        return {} unless search_subauthorities?
        @search_subauthority_replacement_pattern ||= {} if search_config.nil? || !search_subauthorities?
        pattern = search_qa_replacement_patterns[:subauth]
        default = search_url_mappings[pattern.to_sym][:default]
        @search_subauthority_replacement_pattern ||= { pattern: pattern, default: default }
      end

      # Build a linked data authority search url
      # @param [String] the query
      # @param [String] (optional) subauthority key
      # @param [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
      # @return [String] the search encoded url
      def search_url_with_replacements(query, sub_auth = nil, replacements = {})
        return nil unless supports_search?
        sub_auth = sub_auth.to_sym if sub_auth.is_a? String
        url = replace_pattern(search_url_template, search_qa_replacement_patterns[:query], query)
        url = process_subauthority(url, search_subauthority_replacement_pattern, search_subauthorities, sub_auth) if search_subauthorities?
        url = apply_replacements(url, search_replacements, replacements) if search_replacements?
        url
      end
    end
  end
end
