module Qa::Authorities
  module LinkedData
    module SearchQuery
      # Search a linked data authority
      # @param [String] the query
      # @param [Symbol] (optional) language: language used to select literals when multi-language is supported (e.g. :en, :fr, etc.)
      # @param [Hash] (optional) replacements: replacement values with { pattern_name (defined in YAML config) => value }
      # @param [String] subauth: the subauthority to query
      # @return json results
      def search(query, language: nil, replacements: {}, subauth: nil)
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data search sub-authority #{subauth}" unless subauth.nil? || search_subauthority?(subauth)
        language ||= auth_config.search_language
        url = auth_config.search_url_with_replacements(query, subauth, replacements)
        Rails.logger.info "QA Linked Data search url: #{url}"
        graph = get_linked_data(url)
        parse_search_authority_response(graph, language)
      end

      private

        def parse_search_authority_response(graph, language)
          graph = filter_language(graph, language) unless language.nil?
          results = extract_preds(graph, preds_for_search)
          consolidated_results = consolidate_search_results(results)
          json_results = convert_search_to_json(consolidated_results)
          sort_search_results(json_results)
        end

        def preds_for_search
          { required: required_search_preds, optional: optional_search_preds }
        end

        def required_search_preds
          label_pred_uri = auth_config.search_results_label_predicate
          raise Qa::InvalidConfiguration, "required label_predicate is missing in search configuration for LOD authority #{auth_name}" if label_pred_uri.nil?
          { label: label_pred_uri }
        end

        def optional_search_preds
          preds = {}
          preds[:altlabel] = auth_config.search_results_altlabel_predicate unless auth_config.search_results_altlabel_predicate.nil?
          preds[:id] = auth_config.search_results_id_predicate unless auth_config.search_results_id_predicate.nil?
          preds[:sort] = auth_config.search_results_sort_predicate unless auth_config.search_results_sort_predicate.nil?
          preds
        end

        def consolidate_search_results(results)
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
            consolidated_hash[:label] = sort_string_by_language consolidated_hash[:label]
            consolidated_hash[:altlabel] = sort_string_by_language consolidated_hash[:altlabel]
            consolidated_hash[:sort] = sort_string_by_language consolidated_hash[:sort]
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
          json_results.sort! do |a, b|
            unless a.key? :sort
              cmp = -1
              break
            end
            unless b.key? :sort
              cmp = 1
              break
            end
            as = a[:sort].collect(&:downcase)
            bs = b[:sort].collect(&:downcase)
            cmp = 0
            0.upto([as.size, bs.size].max - 1) do |i|
              if as.size <= i
                cmp = -1
                break
              end
              if bs.size <= i
                cmp = 1
                break
              end
              cmp = (as[i] <=> bs[i])
              break if cmp.nonzero?
            end
            cmp
          end
          json_results.each { |h| h.delete(:sort) }
        end
    end
  end
end
