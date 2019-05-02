# This module has the primary QA find method.  It also includes methods to process the linked data result and convert
# it into the expected QA json term result format.
module Qa::Authorities
  module LinkedData
    class FindTerm
      class_attribute :authority_service, :graph_service, :language_service, :language_sort_service, :results_mapper_service
      self.authority_service = Qa::LinkedData::AuthorityUrlService
      self.graph_service = Qa::LinkedData::GraphService
      self.language_service = Qa::LinkedData::LanguageService
      self.language_sort_service = Qa::LinkedData::LanguageSortService
      self.results_mapper_service = Qa::LinkedData::Mapper::TermResultsMapperService

      # @param [TermConfig] term_config The term portion of the config
      def initialize(term_config)
        @term_config = term_config
      end

      attr_reader :term_config, :full_graph, :filtered_graph, :language, :id
      private :full_graph, :filtered_graph, :language, :id

      delegate :term_subauthority?, :prefixes, :authority_name, to: :term_config

      # Find a single term in a linked data authority
      # @param [String] the id of the term to fetch
      # @param [Symbol] (optional) language: language used to select literals when multi-language is supported (e.g. :en, :fr, etc.)
      # @param [Hash] (optional) replacements: replacement values with { pattern_name (defined in YAML config) => value }
      # @param [String] subauth: the subauthority from which to fetch the term
      # @return [String] json results
      # @example Json Results for Linked Data Term
      #   { "uri":"http://id.worldcat.org/fast/530369",
      #     "id":"530369","label":"Cornell University",
      #     "altlabel":["Ithaca (N.Y.). Cornell University"],
      #     "sameas":["http://id.loc.gov/authorities/names/n79021621","https://viaf.org/viaf/126293486"],
      #     "predicates":{
      #     "http://purl.org/dc/terms/identifier":"530369",
      #     "http://www.w3.org/2004/02/skos/core#inScheme":["http://id.worldcat.org/fast/ontology/1.0/#fast","http://id.worldcat.org/fast/ontology/1.0/#facet-Corporate"],
      #     "http://www.w3.org/1999/02/22-rdf-syntax-ns#type":"http://schema.org/Organization",
      #     "http://www.w3.org/2004/02/skos/core#prefLabel":"Cornell University",
      #     "http://schema.org/name":["Cornell University","Ithaca (N.Y.). Cornell University"],
      #     "http://www.w3.org/2004/02/skos/core#altLabel":["Ithaca (N.Y.). Cornell University"],
      #     "http://schema.org/sameAs":["http://id.loc.gov/authorities/names/n79021621","https://viaf.org/viaf/126293486"] } }
      def find(id, language: nil, replacements: {}, subauth: nil, jsonld: false)
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data term sub-authority #{subauth}" unless subauth.nil? || term_subauthority?(subauth)
        @language = language_service.preferred_language(user_language: language, authority_language: term_config.term_language)
        @id = id
        url = authority_service.build_url(action_config: term_config, action: :term, action_request: normalize_id, substitutions: replacements, subauthority: subauth, language: @language)
        Rails.logger.info "QA Linked Data term url: #{url}"
        load_graph(url: url)
        return "{}" unless full_graph.size.positive?
        return full_graph.dump(:jsonld, standard_prefixes: true) if jsonld
        filter_graph
        results = map_results
        convert_results_to_json(results)
      end

      private

        def load_graph(url:)
          @full_graph = graph_service.load_graph(url: url)
          return unless @full_graph.size.positive?
        end

        def filter_graph
          @filtered_graph = graph_service.deep_copy(graph: @full_graph)
          @filtered_graph = graph_service.filter(graph: @filtered_graph, language: language) unless language.blank?
        end

        def map_results
          predicate_map = preds_for_term
          ldpath_map = ldpaths_for_term

          raise Qa::InvalidConfiguration, "do not specify results using both predicates and ldpath in term configuration for LOD authority #{authority_name} (ldpath is preferred)" if predicate_map.present? && ldpath_map.present? # rubocop:disable Metrics/LineLength
          raise Qa::InvalidConfiguration, "must specify label_ldpath or label_predicate in term configuration for LOD authority #{authority_name} (label_ldpath is preferred)" unless ldpath_map.key?(:label) || predicate_map.key?(:label) # rubocop:disable Metrics/LineLength

          if predicate_map.present?
            Qa.deprecation_warning(
              in_msg: 'Qa::Authorities::LinkedData::FindTerm',
              msg: 'defining results using predicates in term config is deprecated; update to define using ldpaths'
            )
          end

          results_mapper_service.map_values(graph: @filtered_graph, subject_uri: uri, prefixes: prefixes,
                                            ldpath_map: ldpaths_for_term, predicate_map: preds_for_term)
        end

        def normalize_id
          return id if expects_uri?
          authority_name.to_s.casecmp('loc').zero? ? id.delete(' ') : id
        end

        def expects_uri?
          term_config.term_id_expects_uri?
        end

        def uri
          return @uri if @uri.present?
          return @uri = RDF::URI.new(id) if expects_uri?
          @uri = graph_service.subjects_for_object_value(graph: @filtered_graph, predicate: RDF::URI.new(term_config.term_results_id_predicate), object_value: id.gsub('%20', ' ')).first
        end

        def ldpaths_for_term
          label_ldpath = term_config.term_results_label_ldpath
          return {} if label_ldpath.blank?
          ldpaths = { label: label_ldpath }
          ldpaths.merge(optional_ldpaths)
        end

        def optional_ldpaths
          opt_ldpaths = {}
          opt_ldpaths[:altlabel] = term_config.term_results_altlabel_ldpath
          opt_ldpaths[:id] = term_config.term_results_id_ldpath
          opt_ldpaths[:narrower] = term_config.term_results_narrower_ldpath
          opt_ldpaths[:broader] = term_config.term_results_broader_ldpath
          opt_ldpaths[:sameas] = term_config.term_results_sameas_ldpath
          opt_ldpaths.delete_if { |_k, v| v.blank? }
        end

        def preds_for_term
          label_pred_uri = term_config.term_results_label_predicate
          return {} if label_pred_uri.blank?
          preds = { label: label_pred_uri }
          preds.merge(optional_preds)
        end

        def optional_preds
          opt_preds = {}
          opt_preds[:altlabel] = term_config.term_results_altlabel_predicate
          opt_preds[:id] = term_config.term_results_id_predicate
          opt_preds[:narrower] = term_config.term_results_narrower_predicate
          opt_preds[:broader] = term_config.term_results_broader_predicate
          opt_preds[:sameas] = term_config.term_results_sameas_predicate
          opt_preds.delete_if { |_k, v| v.blank? }
        end

        def convert_results_to_json(results)
          json_hash = { uri: uri }
          json_hash[:id] = results.key?(:id) && results[:id].present? ? results[:id].first.to_s : uri
          json_hash[:label] = sort_literals(results, :label)
          json_hash.merge!(optional_results_to_json(results))
          predicates_hash = predicates_with_subject_uri(uri)
          json_hash['predicates'] = predicates_hash if predicates_hash.present?
          json_hash
        end

        def optional_results_to_json(results)
          opt_results_json = {}
          opt_results_json[:altlabel] = sort_literals(results, :altlabel)
          opt_results_json[:narrower] = extract_result(results, :narrower)
          opt_results_json[:broader] = extract_result(results, :broader)
          opt_results_json[:sameas] = extract_result(results, :sameas)
          opt_results_json.delete_if { |_k, v| v.blank? }
        end

        def extract_result(results, key)
          return nil unless results.key?(key) || results[key].blank?
          results[key]
        end

        def sort_literals(results, key)
          return nil unless results.key? key
          return [] if results[key].blank?
          language_sort_service.new(results[key], language).uniq_sorted_strings
        end

        def predicates_with_subject_uri(expected_uri) # rubocop:disable Metrics/MethodLength
          predicates_hash = {}
          @full_graph.statements.each do |st|
            subj = st.subject.to_s
            next unless subj == expected_uri
            pred = st.predicate.to_s
            obj  = st.object
            next if obj.anonymous?
            if predicates_hash.key?(pred)
              objs = predicates_hash[pred]
              objs = [] unless objs.is_a?(Array)
              objs << predicates_hash[pred] unless objs.length.positive?
              objs << obj.to_s
              predicates_hash[pred] = objs
            else
              predicates_hash[pred] = [obj.to_s]
            end
          end
          predicates_hash
        end
    end
  end
end
