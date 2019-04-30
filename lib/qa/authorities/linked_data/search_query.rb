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

      attr_reader :search_config, :graph, :language
      private :graph, :language

      delegate :subauthority?, :supports_sort?, :prefixes, :authority_name, to: :search_config

      # Search a linked data authority
      # @praram [String] the query
      # @param language [Symbol] (optional) language used to select literals when multi-language is supported (e.g. :en, :fr, etc.)
      # @param replacements [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
      # @param subauth [String] (optional) the subauthority to query
      # @param context [Boolean] (optional) true if context should be returned with the results; otherwise, false (default: false)
      # @return [String] json results
      # @example Json Results for Linked Data Search
      #   [ {"uri":"http://id.worldcat.org/fast/5140","id":"5140","label":"Cornell, Joseph"},
      #     {"uri":"http://id.worldcat.org/fast/72456","id":"72456","label":"Cornell, Sarah Maria, 1802-1832"},
      #     {"uri":"http://id.worldcat.org/fast/409667","id":"409667","label":"Cornell, Ezra, 1807-1874"} ]
      def search(query, language: nil, replacements: {}, subauth: nil, context: false)
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data search sub-authority #{subauth}" unless subauth.nil? || subauthority?(subauth)
        @context = context
        @language = language_service.preferred_language(user_language: language, authority_language: search_config.language)
        url = authority_service.build_url(action_config: search_config, action: :search, action_request: query, substitutions: replacements, subauthority: subauth, language: @language)
        Rails.logger.info "QA Linked Data search url: #{url}"
        load_graph(url: url)
        results = map_results
        convert_results_to_json(results)
      end

      private

        def load_graph(url:)
          @graph = graph_service.load_graph(url: url)
          @graph = graph_service.filter(graph: @graph, language: language, remove_blanknode_subjects: true)
        end

        def map_results
          predicate_map = preds_for_search
          ldpath_map = ldpaths_for_search

          raise Qa::InvalidConfiguration, "do not specify results using both predicates and ldpath in search configuration for LOD authority #{authority_name} (ldpath is preferred)" if predicate_map.present? && ldpath_map.present? # rubocop:disable Metrics/LineLength
          raise Qa::InvalidConfiguration, "must specify label_ldpath or label_predicate in search configuration for LOD authority #{authority_name} (label_ldpath is preferred)" unless ldpath_map.key?(:label) || predicate_map.key?(:label) # rubocop:disable Metrics/LineLength

          if predicate_map.present?
            Qa.deprecation_warning(
              in_msg: 'Qa::Authorities::LinkedData::SearchQuery',
              msg: 'defining results using predicates in search config is deprecated; update to define using ldpaths'
            )
          end

          results_mapper_service.map_values(graph: @graph, prefixes: prefixes, ldpath_map: ldpath_map,
                                            predicate_map: predicate_map, sort_key: :sort,
                                            preferred_language: @language, context_map: context_map)
        end

        def context_map
          context? ? search_config.context_map : nil
        end

        def context?
          @context == true
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
          label_pred_uri = search_config.results_label_predicate
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
    end
  end
end
