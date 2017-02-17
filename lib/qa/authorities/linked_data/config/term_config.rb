module Qa::Authorities
  module LinkedData
    module TermConfig
      # Return the full configuration for term fetch.
      # @return [String] the term configuration
      def term_config
        config_value(authority_config, 'term')
      end

      # Does this authority configuration have term defined?
      # @return [True|False] true if term fetching is configured; otherwise, false
      def supports_term?
        !term_config.nil?
      end

      # Return term url defined in the configuration for this authority.
      # @return [String] the configured term url
      def term_url
        config_value(term_config, 'url')
      end

      # Is the term_id substitution expected to be a URI?
      # @return [True|False] true if the id substitution is expected to be a URI in the term url; otherwise, false
      def term_id_expects_uri?
        return false if term_config.nil? || !(term_config.key? 'term_id')
        term_config['term_id'] == "URI"
      end

      # Is the term_id substitution expected to be an ID?
      # @return [True|False] true if the id substitution is expected to be an ID in the term url; otherwise, false
      def term_id_expects_id?
        return false if term_config.nil? || !(term_config.key? 'term_id')
        term_config['term_id'] == "ID"
      end

      # Return the preferred language for literal value selection for term fetch.  Only applies if the authority provides language encoded literals.
      # @return [Symbol] the configured language for term fetch (default - :en)
      def term_language
        return @term_language unless @term_language.nil?
        lang = config_value(term_config, 'language')
        return nil if lang.nil?
        lang = [lang] if lang.is_a? String
        @term_language = lang.collect(&:to_sym)
      end

      # Return results id_predicate
      # @return [String] the configured predicate to use to extract the id from the results
      def term_results_id_predicate
        predicate_uri(config_value(term_config, 'results'), 'id_predicate')
      end

      # Return results label_predicate
      # @return [String] the configured predicate to use to extract label values from the results
      def term_results_label_predicate
        predicate_uri(config_value(term_config, 'results'), 'label_predicate')
      end

      # Return results altlabel_predicate
      # @return [String] the configured predicate to use to extract altlabel values from the results
      def term_results_altlabel_predicate
        predicate_uri(config_value(term_config, 'results'), 'altlabel_predicate')
      end

      # Return results broader_predicate
      # @return [String] the configured predicate to use to extract URIs for broader terms from the results
      def term_results_broader_predicate
        predicate_uri(config_value(term_config, 'results'), 'broader_predicate')
      end

      # Return results narrower_predicate
      # @return [String] the configured predicate to use to extract URIs for narrower terms from the results
      def term_results_narrower_predicate
        predicate_uri(config_value(term_config, 'results'), 'narrower_predicate')
      end

      # Return results sameas_predicate
      # @return [String] the configured predicate to use to extract URIs for sameas terms from the results
      def term_results_sameas_predicate
        predicate_uri(config_value(term_config, 'results'), 'sameas_predicate')
      end

      # Are there replacement parameters configured for term fetch?
      # @return [True|False] true if there are replacement parameters configured for term fetch; otherwise, false
      def term_replacements?
        term_replacement_count.positive?
      end

      # Return the number of possible replacement values to make in the term URL
      # @return [Integer] the configured number of possible replacements in the term url
      def term_replacement_count
        @term_replacement_count unless @term_replacement_count.nil?
        cnt = config_value(term_config, 'replacement_count')
        @term_replacement_count = cnt.nil? ? 0 : cnt.to_i
      end

      # Return the replacement configurations
      # @return [Hash] the configurations for term url replacements
      def term_replacements
        @term_replacements ||= replacements_config(term_replacement_count, term_config)
      end

      # Are there subauthorities configured for term fetch?
      # @return [True|False] true if there are subauthorities configured term fetch; otherwise, false
      def term_subauthorities?
        term_subauthority_count.positive?
      end

      # Is a specific subauthority configured for term fetch?
      # @return [True|False] true if the specified subauthority is configured for term fetch; otherwise, false
      def term_subauthority?(subauth_name)
        term_subauthorities.key? subauth_name
      end

      # Return the number of subauthorities defined for term fetch
      # @return [Integer] the number of subauthorities defined for term fetch
      def term_subauthority_count
        term_subauthorities.size
      end

      # Return the list of subauthorities for term fetch
      # @return [Hash] the configurations for term url replacements
      def term_subauthorities
        @term_subauthorities ||= {} if term_config.nil? || !(term_config.key? 'subauthorities')
        @term_subauthorities ||= term_config['subauthorities'].reject { |k, _v| k == 'replacement' }
      end

      # Return the replacement configurations
      # @return [Hash] the configurations for term url replacements
      def term_subauthority_replacement_pattern
        @term_subauthority_replacement_pattern ||= {} if term_config.nil? || !(term_config.key? 'subauthorities')
        @term_subauthority_replacement_pattern ||= { pattern: term_config['subauthorities']['replacement']['pattern'], default: term_config['subauthorities']['replacement']['default'] }
      end

      # Build a linked data authority term url
      # @param [String] the id
      # @param [String] (optional) subauthority key
      # @param [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
      # @return [String] the term encoded url
      def term_url_with_replacements(id, sub_auth = nil, replacements = {})
        return nil unless supports_term?
        url = term_url.gsub(/__TERM_ID__/, id)
        url = process_subauthority(url, term_subauthority_replacement_pattern, term_subauthorities, sub_auth) if term_subauthorities?
        url = apply_replacements(url, term_replacements, replacements) if term_replacements?
        url
      end
    end
  end
end
