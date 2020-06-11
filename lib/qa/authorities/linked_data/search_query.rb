# This module has the primary QA search method.  It also includes methods to process the linked data results and convert
# them into the expected QA json results format.
module Qa::Authorities
  module LinkedData
    class SearchQuery
      class_attribute :authority_service, :graph_service, :language_service, :language_sort_service, :results_mapper_service
      self.authority_service = Qa::LinkedData::AuthorityUrlService
      self.graph_service = Qa::LinkedData::GraphService
      self.language_service = Qa::LinkedData::LanguageService
      self.language_sort_service = Qa::LinkedData::LanguageSortService
      self.results_mapper_service = Qa::LinkedData::Mapper::SearchResultsMapperService

      # @param [SearchConfig] search_config The search portion of the config
      def initialize(search_config)
        @search_config = search_config
      end

      attr_reader :search_config, :full_graph, :filtered_graph, :language, :access_time_s, :normalize_time_s, :subauthority, :request_header, :request_id, :request
      private :full_graph, :filtered_graph, :language, :access_time_s, :normalize_time_s, :subauthority, :request_header, :request_id, :request

      delegate :subauthority?, :supports_sort?, :prefixes, :authority_name, to: :search_config

      # Search a linked data authority
      # @praram [String] the query
      # @param request_header [Hash] optional attributes that can be appended to the generated URL
      # @option language [Symbol] language used to select literals when multi-language is supported (e.g. :en, :fr, etc.)
      # @option replacements [Hash] replacement values with { pattern_name (defined in YAML config) => value }
      # @option subauthority [String] the subauthority to query
      # @option context [Boolean] true if context should be returned with the results; otherwise, false (default: false)
      # @option performance_data [Boolean] true if include_performance_data should be returned with the results; otherwise, false (default: false)
      # @return [String] json results
      # @note All parameters after request_header are deprecated and will be removed in the next major release.
      # @example Json Results for Linked Data Search
      #   [ {"uri":"http://id.worldcat.org/fast/5140","id":"5140","label":"Cornell, Joseph"},
      #     {"uri":"http://id.worldcat.org/fast/72456","id":"72456","label":"Cornell, Sarah Maria, 1802-1832"},
      #     {"uri":"http://id.worldcat.org/fast/409667","id":"409667","label":"Cornell, Ezra, 1807-1874"} ]
      def search(query, request_header: {}, language: nil, replacements: {}, subauth: nil, context: false, performance_data: false) # rubocop:disable Metrics/ParameterLists
        request_header = build_request_header(language: language, replacements: replacements, subauth: subauth, context: context, performance_data: performance_data) if request_header.empty?
        unpack_request_header(request_header)
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data search sub-authority #{subauthority}" unless subauthority.nil? || subauthority?(subauthority)
        url = authority_service.build_url(action_config: search_config, action: :search, action_request: query, request_header: request_header)
        Rails.logger.info "QA Linked Data search url: #{url}"
        load_graph(url: url)
        normalize_results
      end

      private

        def load_graph(url:)
          access_start_dt = Time.now.utc

          @full_graph = graph_service.load_graph(url: url)

          access_end_dt = Time.now.utc
          @access_time_s = access_end_dt - access_start_dt
          Rails.logger.info("Time to receive data from authority: #{access_time_s}s")
        end

        def normalize_results
          normalize_start_dt = Time.now.utc

          @filtered_graph = graph_service.filter(graph: full_graph, language: language)
          results = map_results
          json = convert_results_to_json(results)

          normalize_end_dt = Time.now.utc
          @normalize_time_s = normalize_end_dt - normalize_start_dt
          Rails.logger.info("Time to normalize data: #{normalize_time_s}s")
          json = append_data_outside_results(json)
          json
        end

        def map_results
          predicate_map = preds_for_search
          ldpath_map = ldpaths_for_search

          raise Qa::InvalidConfiguration, "do not specify results using both predicates and ldpath in search configuration for linked data authority #{authority_name} (ldpath is preferred)" if predicate_map.present? && ldpath_map.present? # rubocop:disable Layout/LineLength
          raise Qa::InvalidConfiguration, "must specify label_ldpath or label_predicate in search configuration for linked data authority #{authority_name} (label_ldpath is preferred)" unless ldpath_map.key?(:label) || predicate_map.key?(:label) # rubocop:disable Layout/LineLength

          if predicate_map.present?
            Qa.deprecation_warning(
              in_msg: 'Qa::Authorities::LinkedData::SearchQuery',
              msg: "defining results using predicates in search config is deprecated; update to define using ldpaths (authority: #{authority_name})"
            )
          end

          results_mapper_service.map_values(graph: filtered_graph, prefixes: prefixes, ldpath_map: ldpath_map,
                                            predicate_map: predicate_map, sort_key: :sort,
                                            preferred_language: language, context_map: context_map)
        end

        def unpack_request_header(request_header)
          @request_header = request_header
          @request = request_header.fetch(:request, nil)
          @request_id = request_header.fetch(:request_id, 'UNASSIGNED')
          @subauthority = request_header.fetch(:subauthority, nil)
          @context = request_header.fetch(:context, false)
          @performance_data = request_header.fetch(:performance_data, false)
          @response_header = request_header.fetch(:response_header, false)
          @language = language_service.preferred_language(user_language: request_header.fetch(:user_language, nil),
                                                          authority_language: search_config.language)
          request_header[:language] = Array(@language)
        end

        def context_map
          context? ? search_config.context_map : nil
        end

        def context?
          @context == true
        end

        def performance_data?
          @performance_data == true
        end

        def response_header?
          @response_header == true
        end

        def ldpaths_for_search
          label_ldpath = search_config.results_label_ldpath
          return {} if label_ldpath.blank?
          ldpaths = { label: label_ldpath, uri: :subject_uri }
          ldpaths[:altlabel] = search_config.results_altlabel_ldpath unless search_config.results_altlabel_ldpath.nil?
          ldpaths[:id] = id_ldpath.present? ? id_ldpath : :subject_uri
          ldpaths[:sort] = sort_ldpath.present? ? sort_ldpath : ldpaths[:label]
          ldpaths
        end

        def id_ldpath
          @id_ldpath ||= search_config.results_id_ldpath
        end

        def sort_ldpath
          @sort_ldpath ||= search_config.results_sort_ldpath
        end

        def preds_for_search
          label_pred_uri = search_config.results_label_predicate(suppress_deprecation_warning: true)
          return {} if label_pred_uri.blank?
          preds = { label: label_pred_uri, uri: :subject_uri }
          preds[:altlabel] = search_config.results_altlabel_predicate unless search_config.results_altlabel_predicate.nil?
          preds[:id] = id_predicate.present? ? id_predicate : :subject_uri
          preds[:sort] = sort_predicate.present? ? sort_predicate : preds[:label]
          preds
        end

        def id_predicate
          @id_predicate ||= search_config.results_id_predicate
        end

        def sort_predicate
          @sort_predicate ||= search_config.results_sort_predicate
        end

        def convert_results_to_json(results)
          json_results = []
          results.each { |result| json_results << convert_result_to_json(result) }
          json_results
        end

        def convert_result_to_json(result)
          json_result = {}
          json_result[:uri] = result[:uri].first.to_s
          json_result[:id] = result[:id].any? ? result[:id].first.to_s : ""
          json_result[:label] = full_label(result[:label], result[:altlabel])
          json_result[:context] = result[:context] if context?
          json_result
        end

        def full_label(label = [], altlabel = [])
          label = language_sort_service.new(label, language).sort
          altlabel = language_sort_service.new(altlabel, language).sort
          lbl = wrap_labels(label)
          lbl += " (#{altlabel.join(', ')})" if altlabel.present?
          lbl = lbl.slice(0..95) + '...' if lbl.length > 98
          lbl.strip
        end

        def wrap_labels(labels)
          lbl = "" if labels.nil? || labels.size.zero?
          lbl = labels.join(', ') if labels.size.positive?
          lbl = '[' + lbl + ']' if labels.size > 1
          lbl
        end

        def append_data_outside_results(results)
          return results unless performance_data? || response_header?
          full_results = {}
          full_results[:results] = results
          full_results[:performance] = performance(results) if performance_data?
          full_results[:response_header] = response_header(results) if response_header?
          full_results
        end

        def performance(results)
          Qa::LinkedData::PerformanceDataService.performance_data(access_time_s: access_time_s, normalize_time_s: normalize_time_s,
                                                                  fetched_data_graph: full_graph, normalized_data: results)
        end

        def response_header(results)
          Qa::LinkedData::ResponseHeaderService.new(results: results, request_header: request_header, config: search_config, graph: full_graph).search_header
        end

        # This is providing support for calling build_url with individual parameters instead of the request_header.
        # This is deprecated and will be removed in the next major release.
        def build_request_header(language:, replacements:, subauth:, context:, performance_data:) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          unless language.blank? && replacements.blank? && subauth.blank? && !context && !performance_data
            Qa.deprecation_warning(
              in_msg: 'Qa::Authorities::LinkedData::SearchQuery',
              msg: "individual attributes for options (e.g. replacements, subauth, language) are deprecated; use request_header instead"
            )
          end
          request_header = {}
          request_header[:replacements] = replacements || {}
          request_header[:subauthority] = subauth || nil
          request_header[:language] = language || nil
          request_header[:context] = context
          request_header[:performance_data] = performance_data
          request_header
        end
    end
  end
end
