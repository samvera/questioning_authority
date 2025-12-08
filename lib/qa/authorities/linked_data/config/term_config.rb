# Provide attr_reader methods specific to term configuration for linked data authority configurations.  This is separated
# out for readability and file length.
# @see Qa::Authorities::LinkedData::Config
# @see Qa::Authorities::LinkedData::SearchConfig
module Qa::Authorities
  module LinkedData
    class TermConfig
      attr_reader :prefixes, :full_config, :term_config
      private :full_config, :term_config

      delegate :authority_name, to: :full_config

      # @param [Hash] config the term portion of the config
      # @param [Hash<Symbol><String>] prefixes URL map of prefixes to use with ldpaths
      # @param [Qa::Authorities::LinkedData::Config] full_config the full linked data configuration that the passed in term config is part of
      def initialize(config, prefixes = {}, full_config = nil)
        @term_config = config
        @prefixes = prefixes
        @full_config = full_config
      end

      # Does this authority configuration have term defined?
      # @return [True|False] true if term fetching is configured; otherwise, false
      def supports_term?
        term_config.present?
      end

      # Return term url template defined in the configuration for this authority.
      # @return [Qa::IriTemplate::UrlConfig] the configured term url template
      def url_config
        @url_config ||= Qa::IriTemplate::UrlConfig.new(term_config[:url]) if supports_term?
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
      # This is the default used for this authority if the user does not pass in a language.
      # Only applies if the authority provides language encoded literals.
      # @return [Symbol] the configured language for term fetch (default - :en)
      def term_language
        return @term_language unless @term_language.nil?
        lang = Config.config_value(term_config, :language)
        return nil if lang.nil?
        lang = [lang] if lang.is_a? String
        @term_language = lang.collect(&:to_sym)
      end
      alias language term_language

      # Return results ldpaths or predicates
      # @return [Hash] all the configured ldpaths or predicates to pull out of the results
      def term_results
        Config.config_value(term_config, :results)
      end

      # Return results id_ldpath
      # @return [String] the configured ldpath to use to extract the id from the results
      def term_results_id_ldpath
        Config.config_value(term_results, :id_ldpath)
      end

      # Return results id_predicates
      # @return [Array<String>] the configured predicate to use to extract the id from the results
      def term_results_id_predicates
        @pred_ids ||=
          begin
            pred = Config.predicate_uri(term_results, :id_predicate)
            pred ? [pred] : id_predicates_from_ldpath
          end
      end

      # Return results id_predicate
      # @return [String] the configured predicate to use to extract the id from the results
      # NOTE: Customizations using this method should be updated to use `term_results_id_predicates` which returns [Array<String>] of
      #       id predicates.  This method remains for backward compatibility only but may cause issues if used in places expecting an Array
      def term_results_id_predicate(suppress_deprecation_warning: false)
        unless suppress_deprecation_warning
          Deprecation.warn(
              "`term_results_id_predicate` is deprecated; use `term_results_id_ldpath` by updating linked data " \
                 "term config results in authority #{authority_name} to specify as `id_ldpath`"
            )
        end
        id_predicates = term_results_id_predicates
        id_predicates.first
      end

      # Return results label_ldpath
      # @return [String] the configured ldpath to use to extract label values from the results
      def term_results_label_ldpath
        Config.config_value(term_results, :label_ldpath)
      end

      # Return results label_predicate
      # @return [String] the configured predicate to use to extract label values from the results
      def term_results_label_predicate(suppress_deprecation_warning: false)
        unless suppress_deprecation_warning
          Deprecation.warn(
              "`term_results_label_predicate` is deprecated; use `term_results_label_ldpath` by updating linked data " \
                 "term config results in authority #{authority_name} to specify as `label_ldpath`"
            )
        end
        Config.predicate_uri(term_results, :label_predicate)
      end

      # Return results altlabel_ldpath
      # @return [String] the configured ldpath to use to extract altlabel values from the results
      def term_results_altlabel_ldpath
        Config.config_value(term_results, :altlabel_ldpath)
      end

      # Return results altlabel_predicate
      # @return [String] the configured predicate to use to extract altlabel values from the results
      def term_results_altlabel_predicate
        Deprecation.warn(
            "`term_results_altlabel_predicate` is deprecated; use `term_results_altlabel_ldpath` by updating linked data " \
               "term config results in authority #{authority_name} to specify as `altlabel_ldpath`"
          )
        Config.predicate_uri(term_results, :altlabel_predicate)
      end

      # Return results broader_ldpath
      # @return [String] the configured ldpath to use to extract URIs for broader terms from the results
      def term_results_broader_ldpath
        Config.config_value(term_results, :broader_ldpath)
      end

      # Return results broader_predicate
      # @return [String] the configured predicate to use to extract URIs for broader terms from the results
      def term_results_broader_predicate
        Deprecation.warn(
            "`term_results_broader_predicate` is deprecated; use `term_results_broader_ldpath` by updating linked data " \
               "term config results in authority #{authority_name} to specify as `broader_ldpath`"
          )
        Config.predicate_uri(term_results, :broader_predicate)
      end

      # Return results narrower_ldpath
      # @return [String] the configured ldpath to use to extract URIs for narrower terms from the results
      def term_results_narrower_ldpath
        Config.config_value(term_results, :narrower_ldpath)
      end

      # Return results narrower_predicate
      # @return [String] the configured predicate to use to extract URIs for narrower terms from the results
      def term_results_narrower_predicate
        Deprecation.warn(
          "`term_results_narrower_predicate` is deprecated; use `term_results_narrower_ldpath` by updating linked data " \
               "term config results in authority #{authority_name} to specify as `narrower_ldpath`"
        )
        Config.predicate_uri(term_results, :narrower_predicate)
      end

      # Return results sameas_ldpath
      # @return [String] the configured ldpath to use to extract URIs for sameas terms from the results
      def term_results_sameas_ldpath
        Config.config_value(term_results, :sameas_ldpath)
      end

      # Return results sameas_predicate
      # @return [String] the configured predicate to use to extract URIs for sameas terms from the results
      def term_results_sameas_predicate
        Deprecation.warn(
         "`term_results_sameas_predicate` is deprecated; use `term_results_sameas_ldpath` by updating linked data " \
           "term config results in authority #{authority_name} to specify as `sameas_ldpath`"
       )
        Config.predicate_uri(term_results, :sameas_predicate)
      end

      # Return parameters that are required for QA api
      # @return [Hash] the configured term url parameter mappings
      def term_qa_replacement_patterns
        term_config.fetch(:qa_replacement_patterns, {})
      end
      alias qa_replacement_patterns term_qa_replacement_patterns

      # @return [Boolean] true if supports language parameter; otherwise, false
      def supports_subauthorities?
        qa_replacement_patterns.key?(:subauth) && subauthorities?
      end

      # @return [Boolean] true if supports language parameter; otherwise, false
      def supports_language_parameter?
        qa_replacement_patterns.key? :lang
      end

      # Are there subauthorities configured for term fetch?
      # @return [True|False] true if there are subauthorities configured term fetch; otherwise, false
      def term_subauthorities?
        term_subauthority_count.positive?
      end
      alias subauthorities? term_subauthorities?

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
      alias subauthorities term_subauthorities

      def info
        return [] unless supports_term?
        auth_name = authority_name.downcase.to_s
        language = Qa::LinkedData::LanguageService.preferred_language(authority_language: language).map(&:to_s)
        details = summary_without_subauthority(auth_name, language)
        subauthorities.keys { |subauth_name| details << summary_with_subauthority(auth_name, subauth_name.downcase.to_s, language) }
        details
      end

      private

        # Parse ldpath into an array of predicates.
        # Gets ldpath (e.g. 'loc:lccn | madsrdf:code :: xsd:string') using config accessor for results id ldpath.
        # Multiple paths are delineated by | which is used to split the ldpath into an array of paths.
        # @return [Array<String>] the predicate for each path in the ldpath
        def id_predicates_from_ldpath
          id_ldpath = term_results_id_ldpath
          return [] if id_ldpath.blank?
          id_ldpath.split('|').map(&:strip).map do |path|
            predicate = parse_predicate_from_single_path(path)
            predicate.present? ? RDF::URI.new(predicate) : nil
          end.compact
        end

        # Parse a single path (e.g. 'loc:lccn' where 'loc' is the ontology prefix and 'lccn' is the property name)
        # Gets prefixes (e.g. { "loc": "http://id.loc.gov/vocabulary/identifiers/", "madsrdf": "http://www.loc.gov/mads/rdf/v1#" }) from authority config
        # @return [String] the predicate constructed by combining the expanded prefix with the property name
        def parse_predicate_from_single_path(path)
          tokens = path.split(':')
          return nil if tokens.size < 2
          prefix = tokens.first.to_sym
          prefix_path = prefixes[prefix]
          prefix_path = Qa::LinkedData::LdpathService.predefined_prefixes[prefix] if prefix_path.blank?
          raise Qa::InvalidConfiguration, "Prefix '#{prefix}' is not defined in term configuration for authority #{authority_name}" if prefix_path.blank?
          "#{prefix_path}#{tokens.second.strip}"
        end

        def summary_without_subauthority(auth_name, language)
          [
            {
              "label" => "#{auth_name} term (QA)",
              "uri" => "urn:qa:term:#{auth_name}",
              "authority" => auth_name,
              "action" => "term",
              "language" => language
            }
          ]
        end

        def summary_with_subauthority(auth_name, subauth_name, language)
          {
            "label" => "#{auth_name} term #{subauth_name} (QA)",
            "uri" => "urn:qa:term:#{auth_name}:#{subauth_name}",
            "authority" => auth_name,
            "subauthority" => subauth_name,
            "action" => "term",
            "language" => language
          }
        end
    end
  end
end
