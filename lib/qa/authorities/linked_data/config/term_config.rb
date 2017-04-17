# Provide attr_reader methods specific to term configuration for linked data authority configurations.  This is separated
# out for readability and file length.
# @see Qa::Authorities::LinkedData::Config
# @see Qa::Authorities::LinkedData::SearchConfig
module Qa::Authorities
  module LinkedData
    class TermConfig
      # @param [Hash] config the term portion of the config
      def initialize(config)
        @term_config = config
      end

      attr_reader :term_config
      private :term_config

      # Does this authority configuration have term defined?
      # @return [True|False] true if term fetching is configured; otherwise, false
      def supports_term?
        term_config.present?
      end

      # Return term url encoding defined in the configuration for this authority.
      # @return [Hash] the configured term url
      def term_url
        Config.config_value(term_config, :url)
      end

      # Return term url template defined in the configuration for this authority.
      # @return [String] the configured term url template
      def term_url_template
        Config.config_value(term_url, :template)
      end

      # Return term url parameter mapping defined in the configuration for this authority.
      # @return [Hash] the configured term url parameter mappings with variable name as key
      def term_url_mappings
        return @term_url_mappings unless @term_url_mappings.nil?
        mappings = Config.config_value(term_url, :mapping)
        return {} if mappings.nil?
        Hash[*mappings.collect { |m| [m[:variable].to_sym, m] }.flatten]
      end

      # Is the term_id substitution expected to be a URI?
      # @return [True|False] true if the id substitution is expected to be a URI in the term url; otherwise, false
      def term_id_expects_uri?
        return false if term_config.nil? || !(term_config.key? :term_id)
        term_config[:term_id] == "URI"
      end

      # Is the term_id substitution expected to be an ID?
      # @return [True|False] true if the id substitution is expected to be an ID in the term url; otherwise, false
      def term_id_expects_id?
        return false if term_config.nil? || !(term_config.key? :term_id)
        term_config[:term_id] == "ID"
      end

      # Return the preferred language for literal value selection for term fetch.  Only applies if the authority provides language encoded literals.
      # @return [Symbol] the configured language for term fetch (default - :en)
      def term_language
        return @term_language unless @term_language.nil?
        lang = Config.config_value(term_config, :language)
        return nil if lang.nil?
        lang = [lang] if lang.is_a? String
        @term_language = lang.collect(&:to_sym)
      end

      # Return results predicates
      # @return [Hash] all the configured predicates to pull out of the results
      def term_results
        Config.config_value(term_config, :results)
      end

      # Return results id_predicate
      # @return [String] the configured predicate to use to extract the id from the results
      def term_results_id_predicate
        Config.predicate_uri(term_results, :id_predicate)
      end

      # Return results label_predicate
      # @return [String] the configured predicate to use to extract label values from the results
      def term_results_label_predicate
        Config.predicate_uri(term_results, :label_predicate)
      end

      # Return results altlabel_predicate
      # @return [String] the configured predicate to use to extract altlabel values from the results
      def term_results_altlabel_predicate
        Config.predicate_uri(term_results, :altlabel_predicate)
      end

      # Return results broader_predicate
      # @return [String] the configured predicate to use to extract URIs for broader terms from the results
      def term_results_broader_predicate
        Config.predicate_uri(term_results, :broader_predicate)
      end

      # Return results narrower_predicate
      # @return [String] the configured predicate to use to extract URIs for narrower terms from the results
      def term_results_narrower_predicate
        Config.predicate_uri(term_results, :narrower_predicate)
      end

      # Return results sameas_predicate
      # @return [String] the configured predicate to use to extract URIs for sameas terms from the results
      def term_results_sameas_predicate
        Config.predicate_uri(term_results, :sameas_predicate)
      end

      # Return parameters that are required for QA api
      # @return [Hash] the configured term url parameter mappings
      def term_qa_replacement_patterns
        Config.config_value(term_config, :qa_replacement_patterns)
      end

      # Are there replacement parameters configured for term fetch?
      # @return [True|False] true if there are replacement parameters configured for term fetch; otherwise, false
      def term_replacements?
        term_replacement_count.positive?
      end

      # Return the number of possible replacement values to make in the term URL
      # @return [Integer] the configured number of possible replacements in the term url
      def term_replacement_count
        term_replacements.size
      end

      # Return the replacement configurations
      # @return [Hash] the configurations for term url replacements
      def term_replacements
        return @term_replacements unless @term_replacements.nil?
        @term_replacements = {}
        @term_replacements = term_url_mappings.select { |k, _v| !term_qa_replacement_patterns.include?(k) } unless term_config.nil? || term_url_mappings.nil?
        @term_replacements
      end

      # Are there subauthorities configured for term fetch?
      # @return [True|False] true if there are subauthorities configured term fetch; otherwise, false
      def term_subauthorities?
        term_subauthority_count.positive?
      end

      # Is a specific subauthority configured for term fetch?
      # @return [True|False] true if the specified subauthority is configured for term fetch; otherwise, false
      def term_subauthority?(subauth_name)
        subauth_name = subauth_name.to_sym if subauth_name.is_a? String
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
        @term_subauthorities ||= {} if term_config.nil? || !(term_config.key? :subauthorities)
        @term_subauthorities ||= term_config[:subauthorities]
      end

      # Return the replacement configurations
      # @return [Hash] the configurations for term url replacements
      def term_subauthority_replacement_pattern
        return {} unless term_subauthorities?
        @term_subauthority_replacement_pattern ||= {} if term_config.nil? || !term_subauthorities?
        pattern = term_qa_replacement_patterns[:subauth]
        @term_subauthority_replacement_pattern ||= { pattern: pattern, default: term_url_mappings[pattern.to_sym][:default] }
      end

      # Build a linked data authority term url
      # @param [String] the id
      # @param [String] (optional) subauthority key
      # @param [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
      # @return [String] the term encoded url
      def term_url_with_replacements(id, sub_auth = nil, replacements = {})
        return nil unless supports_term?
        sub_auth = sub_auth.to_sym if sub_auth.is_a? String
        url = Config.replace_pattern(term_url_template, term_qa_replacement_patterns[:term_id], id)
        url = Config.process_subauthority(url, term_subauthority_replacement_pattern, term_subauthorities, sub_auth) if term_subauthorities?
        url = Config.apply_replacements(url, term_replacements, replacements) if term_replacements?
        url
      end
    end
  end
end
