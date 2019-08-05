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

      attr_reader :term_config, :full_graph, :filtered_graph, :language, :id, :uri, :access_time_s, :normalize_time_s, :fetched_size, :normalized_size
      private :full_graph, :filtered_graph, :language, :id, :uri, :access_time_s, :normalize_time_s, :fetched_size, :normalized_size

      delegate :term_subauthority?, :prefixes, :authority_name, to: :term_config

      # Find a single term in a linked data authority
      # @param [String] the id of the term to fetch
      # @param [Symbol] (optional) language: language used to select literals when multi-language is supported (e.g. :en, :fr, etc.)
      # @param [Hash] (optional) replacements: replacement values with { pattern_name (defined in YAML config) => value }
      # @param [String] subauth: the subauthority from which to fetch the term
      # @return [Hash] json results
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
      def find(id, language: nil, replacements: {}, subauth: nil, format: nil, jsonld: false, performance_data: false) # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
        # TODO: When jsonld parameter is removed, the format parameter should default to 'json'.  Not making this change now for backward compatibility of the default for jsonld parameter.
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data term sub-authority #{subauth}" unless subauth.nil? || term_subauthority?(subauth)
        @language = language_service.preferred_language(user_language: language, authority_language: term_config.term_language)
        @id = id
        @performance_data = performance_data
        @format = format
        @jsonld = jsonld if @format.blank?
        if jsonld
          Qa.deprecation_warning(
            in_msg: 'Qa::Authorities::LinkedData::FindTerm',
            msg: "jsonld parameter to find method is deprecated; use `format: 'jsonld'` instead"
          )
        end
        url = authority_service.build_url(action_config: term_config, action: :term, action_request: normalize_id, substitutions: replacements, subauthority: subauth, language: @language)
        Rails.logger.info "QA Linked Data term url: #{url}"
        load_graph(url: url)
        normalize_results
      end

      private

        def load_graph(url:)
          access_start_dt = Time.now.utc

          @full_graph = graph_service.load_graph(url: url)

          access_end_dt = Time.now.utc
          @access_time_s = access_end_dt - access_start_dt
          @fetched_size = full_graph.triples.to_s.size if performance_data?
          Rails.logger.info("Time to receive data from authority: #{access_time_s}s")
        end

        def normalize_results
          normalize_start_dt = Time.now.utc
          normalize_end_dt = Time.now.utc

          json = perform_normalization

          @normalize_time_s = normalize_end_dt - normalize_start_dt
          @normalized_size = json.to_s.size if performance_data?
          Rails.logger.info("Time to convert data to json: #{normalize_time_s}s")
          json = append_performance_data(json) if performance_data?
          json
        end

        def perform_normalization
          return "{}" unless full_graph.size.positive?
          return full_graph.dump(:jsonld, standard_prefixes: true) if jsonld?
          return full_graph.dump(:n3, standard_prefixes: true) if n3?

          filter_graph
          extract_uri
          results = map_results
          convert_results_to_json(results)
        end

        def filter_graph
          @filtered_graph = graph_service.deep_copy(graph: @full_graph)
          @filtered_graph = graph_service.filter(graph: @filtered_graph, language: language) unless language.blank?
        end

        def map_results
          predicate_map = preds_for_term
          ldpath_map = ldpaths_for_term

          raise Qa::InvalidConfiguration, "do not specify results using both predicates and ldpath in term configuration for linked data authority #{authority_name} (ldpath is preferred)" if predicate_map.present? && ldpath_map.present? # rubocop:disable Metrics/LineLength
          raise Qa::InvalidConfiguration, "must specify label_ldpath or label_predicate in term configuration for linked data authority #{authority_name} (label_ldpath is preferred)" unless ldpath_map.key?(:label) || predicate_map.key?(:label) # rubocop:disable Metrics/LineLength

          if predicate_map.present?
            Qa.deprecation_warning(
              in_msg: 'Qa::Authorities::LinkedData::FindTerm',
              msg: "defining results using predicates in term config is deprecated; update to define using ldpaths (authority: #{authority_name})"
            )
          end

          results_mapper_service.map_values(graph: @filtered_graph, subject_uri: uri, prefixes: prefixes,
                                            ldpath_map: ldpaths_for_term, predicate_map: preds_for_term)
        end

        # Special processing for loc ids for backward compatibility.  IDs may be in the form 'n123' or 'n 123'.  URIs do not
        # have a blank.  This removes the <blank> from the ID.
        def normalize_id
          return id if expects_uri?
          loc? ? id.delete(' ') : id
        end

        # Special processing for loc ids for backward compatibility.  IDs may be in the form 'n123' or 'n 123'.  This adds
        # the <blank> into the ID to allow it to be found as the object of a triple in the graph.
        def loc_id
          loc_id = URI.unescape(id)
          digit_idx = loc_id.index(/\d/)
          loc_id.insert(digit_idx, ' ') if loc? && loc_id.index(' ').blank? && digit_idx > 0
          loc_id
        end

        # determine if the current authority is LOC which may require special processing of its ids for backward compatibility
        def loc?
          term_config.url_config.template.starts_with? 'http://id.loc.gov/authorities/'
        end

        def expects_uri?
          term_config.term_id_expects_uri?
        end

        def extract_uri
          return @uri = RDF::URI.new(id) if expects_uri?
          term_config.term_results_id_predicates.each do |id_predicate|
            extract_uri_by_id(id_predicate)
            break if @uri.present?
          end
          raise Qa::DataNormalizationError, "Unable to extract URI based on ID: #{id}" if @uri.blank?
          @uri
        end

        def extract_uri_by_id(id_predicate)
          @uri = graph_service.subjects_for_object_value(graph: @filtered_graph,
                                                         predicate: id_predicate,
                                                         object_value: URI.unescape(id)).first
          return if @uri.present? || !loc?

          # NOTE: Second call to try and extract using the loc_id allows for special processing on the id for LOC authorities.
          #       LOC URIs do not include a blank (e.g. ends with 'n123'), but the ID in the data might (e.g. 'n 123').  If
          #       the ID is provided without the <blank>, this tries a second time to find it with the <blank>.
          @uri = graph_service.subjects_for_object_value(graph: @filtered_graph,
                                                         predicate: id_predicate,
                                                         object_value: URI.unescape(loc_id)).first
          return if @uri.blank? # only show the depercation warning if the loc_id was used
          Qa.deprecation_warning(
            in_msg: 'Qa::Authorities::LinkedData::FindTerm',
            msg: 'Special processing of LOC ids is deprecated; id should be an exact match of the id in the graph'
          )
          @uri
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

        # Give precedent to format parameter over jsonld parameter.  NOTE: jsonld parameter for find method is deprecated.
        def jsonld?
          return @format.casecmp?('jsonld') if @format
          @jsonld == true
        end

        def n3?
          @format && @format.casecmp?('n3')
        end

        def performance_data?
          @performance_data == true && !jsonld?
        end

        def preds_for_term
          label_pred_uri = term_config.term_results_label_predicate(suppress_deprecation_warning: true)
          return {} if label_pred_uri.blank?
          preds = { label: label_pred_uri }
          preds.merge(optional_preds)
        end

        def optional_preds
          opt_preds = {}
          opt_preds[:altlabel] = term_config.term_results_altlabel_predicate
          opt_preds[:id] = term_config.term_results_id_predicates
          opt_preds[:narrower] = term_config.term_results_narrower_predicate
          opt_preds[:broader] = term_config.term_results_broader_predicate
          opt_preds[:sameas] = term_config.term_results_sameas_predicate
          opt_preds.delete_if { |_k, v| v.blank? }
        end

        def convert_results_to_json(results)
          json_hash = { uri: uri.to_s }
          json_hash[:id] = results.key?(:id) && results[:id].present? ? results[:id].first.to_s : uri.to_s
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
          return nil unless results.key?(key) && results[key].present?
          results[key].map(&:to_s)
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

        def append_performance_data(results)
          pred_count = results['predicates'].present? ? results['predicates'].size : 0
          performance = { predicate_count: pred_count,
                          fetch_time_s: access_time_s,
                          normalization_time_s: normalize_time_s,
                          fetched_bytes: fetched_size,
                          normalized_bytes: normalized_size,
                          fetch_bytes_per_s: fetched_size / access_time_s,
                          normalization_bytes_per_s: normalized_size / normalize_time_s,
                          total_time_s: (access_time_s + normalize_time_s) }
          { performance: performance, results: results }
        end
    end
  end
end
