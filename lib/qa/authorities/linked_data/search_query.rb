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

      delegate :subauthority?, :supports_sort?, to: :search_config

      # Search a linked data authority
      # @praram [String] the query
      # @param language [Symbol] (optional) language used to select literals when multi-language is supported (e.g. :en, :fr, etc.)
      # @param replacements [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
      # @param subauth [String] (optional) the subauthority to query
      # @return [String] json results
      # @example Json Results for Linked Data Search
      #   [ {"uri":"http://id.worldcat.org/fast/5140","id":"5140","label":"Cornell, Joseph"},
      #     {"uri":"http://id.worldcat.org/fast/72456","id":"72456","label":"Cornell, Sarah Maria, 1802-1832"},
      #     {"uri":"http://id.worldcat.org/fast/409667","id":"409667","label":"Cornell, Ezra, 1807-1874"} ]
      def search(query, language: nil, replacements: {}, subauth: nil)
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data search sub-authority #{subauth}" unless subauth.nil? || subauthority?(subauth)
        @language = language_service.preferred_language(user_language: language, authority_language: search_config.language)
        url = authority_service.build_url(action_config: search_config, action: :search, action_request: query, substitutions: replacements, subauthority: subauth)
        Rails.logger.info "QA Linked Data search url: #{url}"
        load_graph(url: url)
        parse_search_authority_response
      end

      private

        def load_graph(url:)
          @graph = graph_service.load_graph(url: url)
          @graph = graph_service.filter(graph: @graph, language: language, remove_blanknode_subjects: true)
        end

        def parse_search_authority_response
          results = results_mapper_service.map_values(graph: @graph, predicate_map: preds_for_search, sort_key: :sort,
                                                      preferred_language: @language)
          convert_results_to_json(results)
        end

        def preds_for_search
          label_pred_uri = search_config.results_label_predicate
          raise Qa::InvalidConfiguration, "required label_predicate is missing in search configuration for LOD authority #{auth_name}" if label_pred_uri.nil?
          preds = { label: label_pred_uri }
          preds[:uri] = :subject_uri
          preds[:altlabel] = search_config.results_altlabel_predicate unless search_config.results_altlabel_predicate.nil?
          preds[:id] = search_config.results_id_predicate unless search_config.results_id_predicate.nil?
          preds[:sort] = sort_predicate.present? ? sort_predicate : preds[:label]
          preds
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
          json_result[:id] = result[:id].first.to_s
          json_result[:label] = full_label(result[:label], result[:altlabel])
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
