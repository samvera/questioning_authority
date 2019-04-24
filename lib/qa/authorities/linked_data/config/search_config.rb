# Provide attr_reader methods specific to search configuration for linked data authority configurations.  This is separated
# out for readability and file length.
# @see Qa::Authorities::LinkedData::Config
# @see Qa::Authorities::LinkedData::TermConfig
module Qa::Authorities
  module LinkedData
    class SearchConfig
      attr_reader :prefixes, :full_config, :search_config
      private :full_config, :search_config

      delegate :authority_name, to: :full_config

      # @param [Hash] config the search portion of the config
      # @param [Hash<Symbol><String>] prefixes URL map of prefixes to use with ldpaths
      # @param [Qa::Authorities::LinkedData::Config] full_config the full linked data configuration that the passed in search config is part of
      def initialize(config, prefixes = {}, full_config = nil)
        @search_config = config
        @prefixes = prefixes
        @full_config = full_config
      end

      # Does this authority configuration have search defined?
      # @return [Boolean] true if search is configured; otherwise, false
      def supports_search?
        search_config.present?
      end

      # Return search url template defined in the configuration for this authority.
      # @return [Qa::IriTemplate::UrlConfig] the configured search url template
      def url_config
        @url_config ||= Qa::IriTemplate::UrlConfig.new(search_config[:url]) if supports_search?
      end

      # Return the preferred language for literal value selection for search query.
      # This is the default used for this authority if the user does not pass in a language.
      # Only applies if the authority provides language encoded literals.
      # @return [String] the configured language for search query
      def language
        return @language unless @language.nil?
        lang = search_config[:language]
        return nil if lang.nil?
        lang = [lang] if lang.is_a? String
        @language = lang.collect(&:to_sym)
      end

      # Return results ldpaths or predicates if specified
      # @return [Hash,NilClass] all the configured ldpaths or predicates to pull out of the results
      def results
        search_config[:results]
      end

      # Return results id_ldpath
      # @return [String] the configured ldpath to use to extract the id from the results
      def results_id_ldpath
        Config.config_value(results, :id_ldpath)
      end

      # Return results id_predicate
      # @return [String] the configured predicate to use to extract the id from the results
      def results_id_predicate
        Qa.deprecation_warning(
          in_msg: 'Qa::Authorities::LinkedData::SearchConfig',
          msg: "`results_id_predicate` is deprecated; use `results_id_ldpath` by updating linked data search config results to specify as `id_ldpath`"
        )
        Config.predicate_uri(results, :id_predicate)
      end

      # Return results label_ldpath
      # @return [String] the configured ldpath to use to extract label values from the results
      def results_label_ldpath
        Config.config_value(results, :label_ldpath)
      end

      # Return results label_predicate
      # @return [String] the configured predicate to use to extract label values from the results
      def results_label_predicate
        Qa.deprecation_warning(
          in_msg: 'Qa::Authorities::LinkedData::SearchConfig',
          msg: "`results_label_predicate` is deprecated; use `results_label_ldpath` by updating linked data search config results to specify as `label_ldpath`"
        )
        Config.predicate_uri(results, :label_predicate)
      end

      # Return results altlabel_ldpath
      # @return [String] the configured ldpath to use to extract altlabel values from the results
      def results_altlabel_ldpath
        Config.config_value(results, :altlabel_ldpath)
      end

      # Return results altlabel_predicate
      # @return [String] the configured predicate to use to extract altlabel values from the results
      def results_altlabel_predicate
        Qa.deprecation_warning(
          in_msg: 'Qa::Authorities::LinkedData::SearchConfig',
          msg: "`results_altlabel_predicate` is deprecated; use `results_altlabel_ldpath` by updating linked data search config results to specify as `altlabel_ldpath`"
        )
        Config.predicate_uri(results, :altlabel_predicate)
      end

      # Does this authority configuration support sorting of search results?
      # @return [True|False] true if sorting of search results is supported; otherwise, false
      def supports_sort?
        return true unless results_sort_ldpath.present? || !results_sort_predicate.present?
        false
      end

      # Return results sort_ldpath
      # @return [String] the configured ldpath to use for sorting results from the query search
      def results_sort_ldpath
        Config.config_value(results, :sort_ldpath)
      end

      # Return results sort_predicate
      # @return [String] the configured predicate to use for sorting results from the query search
      def results_sort_predicate
        Qa.deprecation_warning(
          in_msg: 'Qa::Authorities::LinkedData::SearchConfig',
          msg: "`results_sort_predicate` is deprecated; use `results_sort_ldpath` by updating linked data search config results to specify as `sort_ldpath`"
        )
        Config.predicate_uri(results, :sort_predicate)
      end

      # Does this authority configuration support additional context in search results?
      # @return [True|False] true if additional context in search results is supported; otherwise, false
      def supports_context?
        return true if context_map.present?
        false
      end

      # Return the context map if it is defined
      # @return [Qa::LinkedData::Config::ContextMap] the context map
      def context_map
        return nil unless search_config.key?(:context)
        @context_map ||= Qa::LinkedData::Config::ContextMap.new(search_config.fetch(:context), prefixes)
      end

      # Return parameters that are supported directly by QA api (e.g. q, subauth, lang)
      # @return [Hash] the configured search url parameter mappings
      def qa_replacement_patterns
        search_config.fetch(:qa_replacement_patterns, {})
      end

      # @return [Boolean] true if supports language parameter; otherwise, false
      def supports_subauthorities?
        qa_replacement_patterns.key?(:subauth) && subauthorities?
      end

      # @return [Boolean] true if supports language parameter; otherwise, false
      def supports_language_parameter?
        qa_replacement_patterns.key? :lang
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
    end
  end
end
