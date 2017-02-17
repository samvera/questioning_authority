module Qa::Authorities
  module LinkedData
    module SearchConfig
      # Return the full configuration for search query
      # @return [String] the search configuration
      def search_config
        config_value(authority_config, 'search')
      end

      # Does this authority configuration have search defined?
      # @return [True|False] true if search is configured; otherwise, false
      def supports_search?
        !search_config.nil?
      end

      # Return search url defined in the configuration for this authority.
      # @return [String] the configured search url
      def search_url
        config_value(search_config, 'url')
      end

      # Return the preferred language for literal value selection for search query.  Only applies if the authority provides language encoded literals.
      # @return [String] the configured language for search query
      def search_language
        return @search_language unless @search_language.nil?
        lang = config_value(search_config, 'language')
        return nil if lang.nil?
        lang = [lang] if lang.is_a? String
        @search_language = lang.collect(&:to_sym)
      end

      # Return results id_predicate
      # @return [String] the configured predicate to use to extract the id from the results
      def search_results_id_predicate
        predicate_uri(config_value(search_config, 'results'), 'id_predicate')
      end

      # Return results label_predicate
      # @return [String] the configured predicate to use to extract label values from the results
      def search_results_label_predicate
        predicate_uri(config_value(search_config, 'results'), 'label_predicate')
      end

      # Return results altlabel_predicate
      # @return [String] the configured predicate to use to extract altlabel values from the results
      def search_results_altlabel_predicate
        predicate_uri(config_value(search_config, 'results'), 'altlabel_predicate')
      end

      # Return results sort_predicate
      # @return [String] the configured predicate to use for sorting results from the query search
      def search_results_sort_predicate
        predicate_uri(config_value(search_config, 'results'), 'sort_predicate')
      end

      # Are there replacement parameters configured for search query?
      # @return [True|False] true if there are replacement parameters configured for search query; otherwise, false
      def search_replacements?
        search_replacement_count.positive?
      end

      # Return the number of possible replacement values to make in the search URL
      # @return [Integer] the configured number of possible replacements in the search url
      def search_replacement_count
        @search_replacement_count unless @search_replacement_count.nil?
        cnt = config_value(search_config, 'replacement_count')
        @search_replacement_count = cnt.nil? ? 0 : cnt.to_i
      end

      # Return the replacement configurations
      # @return [Hash] the configurations for search url replacements
      def search_replacements
        @search_replacements ||= replacements_config(search_replacement_count, search_config)
      end

      # Are there subauthorities configured for search query?
      # @return [True|False] true if there are subauthorities configured for search query; otherwise, false
      def search_subauthorities?
        search_subauthority_count.positive?
      end

      # Is a specific subauthority configured for search query?
      # @return [True|False] true if the specified subauthority is configured for search query; otherwise, false
      def search_subauthority?(subauth_name)
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
        @search_subauthorities ||= {} if search_config.nil? || !(search_config.key? 'subauthorities')
        @search_subauthorities ||= config_value(search_config, 'subauthorities').reject { |k, _v| k == 'replacement' }
      end

      # Return the replacement configurations
      # @return [Hash] the configurations for search url replacements
      def search_subauthority_replacement_pattern
        @search_subauthority_replacement_pattern ||= {} if search_config.nil? || !(search_config.key? 'subauthorities')
        @search_subauthority_replacement_pattern ||= { pattern: search_config['subauthorities']['replacement']['pattern'], default: search_config['subauthorities']['replacement']['default'] }
      end

      # Build a linked data authority search url
      # @param [String] the query
      # @param [String] (optional) subauthority key
      # @param [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
      # @return [String] the search encoded url
      def search_url_with_replacements(query, sub_auth = nil, replacements = {})
        return nil unless supports_search?
        url = search_url.gsub(/__QUERY__/, query)
        url = process_subauthority(url, search_subauthority_replacement_pattern, search_subauthorities, sub_auth) if search_subauthorities?
        url = apply_replacements(url, search_replacements, replacements) if search_replacements?
        url
      end
    end
  end
end
