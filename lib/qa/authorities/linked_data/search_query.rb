# This module has the primary QA search method.  It also includes methods to process the linked data results and convert
# them into the expected QA json results format.
module Qa::Authorities
  module LinkedData
    class SearchQuery
      include Qa::Authorities::LinkedData::RdfHelper

      # @param [SearchConfig] search_config The search portion of the config
      def initialize(search_config)
        @search_config = search_config
      end

      attr_reader :search_config, :graph, :language
      private :language

      delegate :subauthority?, :supports_sort?, to: :search_config

      # Search a linked data authority
      # @param [String] the query
      # @param [Symbol] (optional) language: language used to select literals when multi-language is supported (e.g. :en, :fr, etc.)
      # @param [Hash] (optional) replacements: replacement values with { pattern_name (defined in YAML config) => value }
      # @param [String] subauth: the subauthority to query
      # @return [String] json results
      # @example Json Results for Linked Data Search
      #   [ {"uri":"http://id.worldcat.org/fast/5140","id":"5140","label":"Cornell, Joseph"},
      #     {"uri":"http://id.worldcat.org/fast/72456","id":"72456","label":"Cornell, Sarah Maria, 1802-1832"},
      #     {"uri":"http://id.worldcat.org/fast/409667","id":"409667","label":"Cornell, Ezra, 1807-1874"} ]
      def search(query, language: nil, replacements: {}, subauth: nil)
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data search sub-authority #{subauth}" unless subauth.nil? || subauthority?(subauth)
        language ||= search_config.language
        @language = language
        url = Qa::LinkedData::AuthorityUrlService.build_url(action_config: search_config, action: :search, action_request: query, substitutions: replacements, subauthority: subauth)
        Rails.logger.info "QA Linked Data search url: #{url}"
        load_graph(url: url)
        parse_search_authority_response
      end

      private

        def load_graph(url:)
          @graph = Qa::LinkedData::GraphService.load_graph(url: url)
          @graph = Qa::LinkedData::GraphService.filter(graph: @graph, language: language, remove_blanknode_subjects: true)
        end

        def parse_search_authority_response
          results = extract_preds(graph, preds_for_search)
          consolidated_results = consolidate_search_results(results)
          json_results = convert_search_to_json(consolidated_results)
          sort_search_results(json_results)
        end

        def preds_for_search
          { required: required_search_preds, optional: optional_search_preds }
        end

        def required_search_preds
          label_pred_uri = search_config.results_label_predicate
          raise Qa::InvalidConfiguration, "required label_predicate is missing in search configuration for LOD authority #{auth_name}" if label_pred_uri.nil?
          { label: label_pred_uri }
        end

        def optional_search_preds
          preds = {}
          preds[:altlabel] = search_config.results_altlabel_predicate unless search_config.results_altlabel_predicate.nil?
          preds[:id] = search_config.results_id_predicate unless search_config.results_id_predicate.nil?
          preds[:sort] = search_config.results_sort_predicate unless search_config.results_sort_predicate.nil?
          preds
        end

        def consolidate_search_results(results) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          consolidated_results = {}
          return consolidated_results if results.nil? || !results.count.positive?
          results.each do |statement|
            stmt_hash = statement.to_h
            uri = stmt_hash[:uri].to_s
            consolidated_hash = init_consolidated_hash(consolidated_results, uri, stmt_hash[:id].to_s)

            consolidated_hash[:label] = object_value(stmt_hash, consolidated_hash, :label, false)
            consolidated_hash[:altlabel] = object_value(stmt_hash, consolidated_hash, :altlabel, false)
            consolidated_hash[:sort] = object_value(stmt_hash, consolidated_hash, :sort, false)
            consolidated_results[uri] = consolidated_hash
          end
          consolidated_results.each do |res|
            consolidated_hash = res[1]
            consolidated_hash[:label] = Qa::LinkedData::LanguageSortService.new(consolidated_hash[:label], language).sort
            consolidated_hash[:altlabel] = Qa::LinkedData::LanguageSortService.new(consolidated_hash[:altlabel], language).sort
            consolidated_hash[:sort] = Qa::LinkedData::LanguageSortService.new(consolidated_hash[:sort], language).sort
          end
          consolidated_results
        end

        def convert_search_to_json(consolidated_results)
          json_results = []
          consolidated_results.each do |uri, h|
            json_results << { uri: uri, id: h[:id], label: full_label(h[:label], h[:altlabel]), sort: h[:sort] }
          end
          json_results
        end

        def full_label(label = [], altlabel = [])
          lbl = wrap_labels(label)
          lbl += " (#{altlabel.join(', ')})" unless altlabel.nil? || altlabel.length <= 0
          lbl = lbl.slice(0..95) + '...' if lbl.length > 98
          lbl.strip
        end

        def wrap_labels(labels)
          lbl = "" if labels.nil? || labels.size.zero?
          lbl = labels.join(', ') if labels.size.positive?
          lbl = '[' + lbl + ']' if labels.size > 1
          lbl
        end

        def sort_search_results(json_results)
          return json_results unless supports_sort?
          return json_results if json_results.empty?
          sort_key = json_results.first.key?(:sort) ? :sort : :label
          json_results = Qa::LinkedData::DeepSortService.new(json_results, sort_key, language).sort
          json_results.each { |h| h.delete(:sort) }
        end
    end
  end
end
