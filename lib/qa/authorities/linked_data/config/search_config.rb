# Provide attr_reader methods specific to search configuration for linked data authority configurations.  This is separated
# out for readability and file length.
# @see Qa::Authorities::LinkedData::Config
# @see Qa::Authorities::LinkedData::TermConfig
module Qa::Authorities
  module LinkedData
    class SearchConfig
      # @param [Hash] config the search portion of the config
      def initialize(config)
        @search_config = config
      end

      attr_reader :search_config
      private :search_config

      # Does this authority configuration have search defined?
      # @return [Boolean] true if search is configured; otherwise, false
      def supports_search?
        search_config.present?
      end

      # Return search url encoding defined in the configuration for this authority
      # if it was provided
      # @return [Hash,NilClass] the configured search url
      def url
        search_config[:url]
      end

      # Return search url template defined in the configuration for this authority.
      # @return [String] the configured search url template
      def url_template
        url.fetch(:template)
      end

      # Return search url parameter mapping defined in the configuration for this authority.
      # @return [Hash] the configured search url parameter mappings with variable name as key
      def url_mappings
        return @url_mappings unless @url_mappings.nil?
        mappings = Config.config_value(url, :mapping)
        return {} if mappings.nil?
        Hash[*mappings.collect { |m| [m[:variable].to_sym, m] }.flatten]
      end

      # Return the preferred language for literal value selection for search query.
      # Only applies if the authority provides language encoded literals.
      # @return [String] the configured language for search query
      def language
        return @language unless @language.nil?
        lang = search_config[:language]
        return nil if lang.nil?
        lang = [lang] if lang.is_a? String
        @language = lang.collect(&:to_sym)
      end

      # Return results predicates if specified
      # @return [Hash,NilClass] all the configured predicates to pull out of the results
      def results
        search_config[:results]
      end

      # Return results id_predicate
      # @return [String] the configured predicate to use to extract the id from the results
      def results_id_predicate
        Config.predicate_uri(results, :id_predicate)
      end

      # Return results label_predicate
      # @return [String] the configured predicate to use to extract label values from the results
      def results_label_predicate
        Config.predicate_uri(results, :label_predicate)
      end

      # Return results altlabel_predicate
      # @return [String] the configured predicate to use to extract altlabel values from the results
      def results_altlabel_predicate
        Config.predicate_uri(results, :altlabel_predicate)
      end

      # Does this authority configuration support sorting of search results?
      # @return [True|False] true if sorting of search results is supported; otherwise, false
      def supports_sort?
        return true unless results_sort_predicate.nil? || !results_sort_predicate.size.positive?
        false
      end

      # Return results sort_predicate
      # @return [String] the configured predicate to use for sorting results from the query search
      def results_sort_predicate
        Config.predicate_uri(results, :sort_predicate)
      end

      # Return parameters that are required for QA api
      # @return [Hash] the configured search url parameter mappings
      def qa_replacement_patterns
        search_config.fetch(:qa_replacement_patterns)
      end

      # Are there replacement parameters configured for search query?
      # @return [True|False] true if there are replacement parameters configured for search query; otherwise, false
      def replacements?
        replacement_count.positive?
      end

      # Return the number of possible replacement values to make in the search URL
      # @return [Integer] the configured number of possible replacements in the search url
      def replacement_count
        replacements.size
      end

      # Return the replacement configurations
      # @return [Hash] the configurations for search url replacements
      def replacements
        return @replacements unless @replacements.nil?
        @replacements = {}
        @replacements = url_mappings.select { |k, _v| !qa_replacement_patterns.include?(k) } unless search_config.nil? || url_mappings.nil?
        @replacements
      end

      # Are there subauthorities configured for search query?
      # @return [True|False] true if there are subauthorities configured for search query; otherwise, false
      def subauthorities?
        subauthority_count.positive?
      end

      # Is a specific subauthority configured for search query?
      # @return [True|False] true if the specified subauthority is configured for search query; otherwise, false
      def subauthority?(subauth_name)
        subauth_name = subauth_name.to_sym if subauth_name.is_a? String
        subauthorities.key? subauth_name
      end

      # Return the number of subauthorities defined for search query
      # @return [Integer] the number of subauthorities defined for search query
      def subauthority_count
        subauthorities.size
      end

      # Return the list of subauthorities for search query
      # @return [Hash] the configurations for search url replacements
      def subauthorities
        @subauthorities ||= {} if search_config.nil? || !(search_config.key? :subauthorities)
        @subauthorities ||= search_config.fetch(:subauthorities)
      end

      # Return the replacement configurations
      # @return [Hash] the configurations for search url replacements
      def subauthority_replacement_pattern
        return {} unless subauthorities?
        @subauthority_replacement_pattern ||= {} if search_config.nil? || !subauthorities?
        pattern = qa_replacement_patterns[:subauth]
        default = url_mappings[pattern.to_sym][:default]
        @subauthority_replacement_pattern ||= { pattern: pattern, default: default }
      end

      # Build a linked data authority search url
      # @param [String] the query
      # @param [String] (optional) subauthority key
      # @param [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
      # @return [String] the search encoded url
      def url_with_replacements(query, sub_auth = nil, search_replacements = {})
        return nil unless supports_search?
        sub_auth = sub_auth.to_sym if sub_auth.is_a? String
        url = Config.replace_pattern(url_template, qa_replacement_patterns[:query], query)
        url = Config.process_subauthority(url, subauthority_replacement_pattern, subauthorities, sub_auth) if subauthorities?
        url = Config.apply_replacements(url, replacements, search_replacements) if replacements?
        url
      end
    end
  end
end
