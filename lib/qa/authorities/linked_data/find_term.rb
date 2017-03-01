# This module has the primary QA find method.  It also includes methods to process the linked data result and convert
# it into the expected QA json term result format.
module Qa::Authorities
  module LinkedData
    class FindTerm
      include Qa::Authorities::LinkedData::RdfHelper

      # @param [TermConfig] term_config The term portion of the config
      def initialize(term_config)
        @term_config = term_config
      end

      attr_reader :term_config

      delegate :term_subauthority?, to: :term_config

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
      def find(id, language: nil, replacements: {}, subauth: nil)
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data term sub-authority #{subauth}" unless subauth.nil? || term_subauthority?(subauth)
        language ||= term_config.term_language
        url = term_config.term_url_with_replacements(id, subauth, replacements)
        Rails.logger.info "QA Linked Data term url: #{url}"
        graph = get_linked_data(url)
        return "{}" unless graph.size.positive?
        parse_term_authority_response(id, graph, language)
      end

      private

        def parse_term_authority_response(id, graph, language)
          graph = filter_language(graph, language) unless language.nil?
          results = extract_preds(graph, preds_for_term)
          consolidated_results = consolidate_term_results(results)
          json_results = convert_term_to_json(consolidated_results)
          termhash = select_json_result_for_id(json_results, id)
          predicates_hash = predicates_with_subject_uri(graph, termhash[:uri])
          termhash['predicates'] = predicates_hash unless predicates_hash.length <= 0
          termhash
        end

        def preds_for_term
          { required: required_term_preds, optional: optional_term_preds }
        end

        def required_term_preds
          label_pred_uri = term_config.term_results_label_predicate
          raise Qa::InvalidConfiguration, "required label_predicate is missing in configuration for LOD authority #{auth_name}" if label_pred_uri.nil?
          { label: label_pred_uri }
        end

        def optional_term_preds
          preds = {}
          preds[:altlabel] = term_config.term_results_altlabel_predicate unless term_config.term_results_altlabel_predicate.nil?
          preds[:id] = term_config.term_results_id_predicate unless term_config.term_results_id_predicate.nil?
          preds[:narrower] = term_config.term_results_narrower_predicate unless term_config.term_results_narrower_predicate.nil?
          preds[:broader] = term_config.term_results_broader_predicate unless term_config.term_results_broader_predicate.nil?
          preds[:sameas] = term_config.term_results_sameas_predicate unless term_config.term_results_sameas_predicate.nil?
          preds
        end

        def consolidate_term_results(results)
          consolidated_results = {}
          results.each do |statement|
            stmt_hash = statement.to_h
            uri = stmt_hash[:uri].to_s
            consolidated_hash = init_consolidated_hash(consolidated_results, uri, stmt_hash[:id].to_s)

            consolidated_hash[:label] = object_value(stmt_hash, consolidated_hash, :label, false)
            altlabel = object_value(stmt_hash, consolidated_hash, :altlabel, false)
            narrower = object_value(stmt_hash, consolidated_hash, :narrower)
            broader = object_value(stmt_hash, consolidated_hash, :broader)
            sameas = object_value(stmt_hash, consolidated_hash, :sameas)

            consolidated_hash[:altlabel] = altlabel unless altlabel.nil?
            consolidated_hash[:narrower] = narrower unless narrower.nil?
            consolidated_hash[:broader] = broader unless broader.nil?
            consolidated_hash[:sameas] = sameas unless sameas.nil?
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

        def convert_term_to_json(consolidated_results)
          json_results = []
          consolidated_results.each do |uri, h|
            json_hash = { uri: uri, id: h[:id], label: h[:label] }
            json_hash[:altlabel] = h[:altlabel] unless h[:altlabel].nil?
            json_hash[:narrower] = h[:narrower] unless h[:narrower].nil?
            json_hash[:broader] = h[:broader] unless h[:broader].nil?
            json_hash[:sameas] = h[:sameas] unless h[:sameas].nil?
            json_results << json_hash
          end
          json_results
        end

        def select_json_result_for_id(json_results, id)
          json_results.select! { |r| r[:uri].include? id } if json_results.size > 1
          json_results.select! { |r| r[:uri].ends_with? id } if json_results.size > 1
          json_results.first
        end

        def predicates_with_subject_uri(graph, expected_uri)
          predicates_hash = {}
          graph.statements.each do |st|
            subj = st.subject.to_s
            next unless subj == expected_uri
            pred = st.predicate.to_s
            obj  = st.object.to_s
            next if blank_node? obj
            if predicates_hash.key?(pred)
              objs = predicates_hash[pred]
              objs = [] unless objs.is_a?(Array)
              objs << predicates_hash[pred] unless objs.length.positive?
              objs << obj
              predicates_hash[pred] = objs
            else
              predicates_hash[pred] = [obj]
            end
          end
          predicates_hash
        end
    end
  end
end
