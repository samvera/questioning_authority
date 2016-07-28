require 'rdf'
require	'linkeddata'
module Qa::Authorities
  # A wrapper around configured linked data authorities for use with questioning_authority
  class LinkedData::GenericAuthority < Base
    attr_reader :auth_config
    attr_reader :auth_name
    attr_reader :search_subauth_name
    attr_reader :term_subauth_name
    attr_reader :search_subauth_config
    attr_reader :term_subauth_config

    def initialize(auth_name,search_subauth_name=nil,term_subauth_name=nil)
      @auth_name = auth_name
      @auth_config = LINKED_DATA_AUTHORITIES_CONFIG[auth_name]
      raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data authority #{auth_name}" if @auth_config.nil?
      @search_subauth_config = @auth_config['search']['subauthorities'] unless @auth_config['search'].nil? || !(@auth_config['search'].key? 'subauthorities')
      @term_subauth_config = @auth_config['term']['subauthorities'] unless @auth_config['term'].nil? || !(@auth_config['term'].key? 'subauthorities')
      unless search_subauth_name.nil?
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data search sub-authority #{search_subauth_name}" unless valid_search_subauthority? search_subauth_name
        @search_subauth_name = search_subauth_name
      end
      unless term_subauth_name.nil?
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data term sub-authority #{term_subauth_name}" unless valid_term_subauthority? term_subauth_name
        @term_subauth_name = term_subauth_name
      end
    end

    def has_search_subauthorities?
      return false if search_subauth_config.nil?
      true
    end

    def valid_search_subauthority? subauth_name
      return false unless has_search_subauthorities?
      return true if search_subauth_config.key? subauth_name
      false
    end

    def has_term_subauthorities?
      return false if term_subauth_config.nil?
      true
    end

    def valid_term_subauthority? subauth_name
      return false unless has_term_subauthorities?
      return true if term_subauth_config.key? subauth_name
      false
    end

    def is_subauthority?
      return false if search_subauth_name.nil? && term_subauth_name.nil?
      true
    end

    include WebServiceBase

    # Find a single term in a linked data authority
    #
    # @param [String] the id
    # @param [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
    # @return json results
    def find id, language=nil, replacements={}
      language = term_language(language)
      url = build_term_url(id, replacements)
      Rails.logger.info "QA Linked Data term url: #{url}"
      graph = get_linked_data(url,@auth_config['term']['http_accept'],language)
      parse_term_authority_response(graph,language)
    end

    # Search a linked data authority
    #
    # @param [String] the query
    # @param [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
    # @return json results
    def search query, language=nil, replacements={}
      language = search_language(language)
      url = build_search_url(query, replacements)
      Rails.logger.info "QA Linked Data search url: #{url}"
      graph = get_linked_data(url,@auth_config['search']['http_accept'],language)
      parse_search_authority_response(graph,language)
    end

    # Build a linked data authority search url
    #
    # @param [String] the query
    # @param [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
    # @return [String] the query encoded url
    def build_search_url query, replacements={}
      escaped_query = clean_query_string query
      url = @auth_config['search']['url'].gsub(/__QUERY__/, escaped_query)
      url = process_subauthority(search_subauth_config, search_subauth_name, url) if has_search_subauthorities?
      rep_count = @auth_config['search']['replacement_count'] || 0
      apply_replacements( url, rep_count, @auth_config['search'], replacements )
    end


    # Build a linked data authority term url
    #
    # @param [String] the id
    # @param [Hash] (optional) replacement values with { pattern_name (defined in YAML config) => value }
    # @return [String] the term encoded url
    def build_term_url id, replacements={}
      escaped_id = clean_query_string id
      url = @auth_config['term']['url'].gsub(/__TERM_ID__/, escaped_id)
      url = process_subauthority(term_subauth_config, term_subauth_name, url) if has_term_subauthorities?
      rep_count = @auth_config['term']['replacement_count'] || 0
      apply_replacements( url, rep_count, @auth_config['term'], replacements )
    end

    private

      # Removes characters from the query string that are not tolerated by the API
      #   See oclc sample code at
      #   http://experimental.worldcat.org/fast/assignfast/js/assignFASTComplete.js
      def clean_query_string q
        URI.escape(q.gsub(/-|\(|\)|:/, ""))
      end

      def process_subauthority( config, subauth_name, url )
        subauth_rep = config['replacement']
        pattern = subauth_rep["pattern"]
        value = config[subauth_name] || subauth_rep["default"]
        url.gsub(pattern,value)
      end

      def apply_replacements( url, rep_count, rep_config, replacements )
        return url if rep_count <= 0
        1.upto(rep_count) do |i|
          rep = rep_config["replacement_#{i}"]
          param_name = rep["param"]
          pattern = rep["pattern"]
          value = replacements[param_name] || rep["default"]
          url = url.gsub(pattern,value)
        end
        url
      end

      def get_linked_data(url,http_accept='application/rdf+xml',language)
        uri = URI(url)
        req = Net::HTTP::Get.new(uri)
        req['Accept'] = http_accept
        req['Accept-Langauge'] = language unless language.nil?

        res = fetch(uri,req,3)
        #       open 'cached_response', 'w' do |io|
        #         io.write res.body
        #       end if res.is_a?(Net::HTTPSuccess)
        build_graph(res.content_type,res.body)
      end

      def fetch(uri, req, limit = 10)
        # You should choose a better exception.
        raise ArgumentError, 'too many HTTP redirects' if limit == 0
        response = Net::HTTP.start(uri.hostname, uri.port) {|http|
          http.request(req)
        }

        case response
          when Net::HTTPSuccess then
            response
          when Net::HTTPRedirection then
            location = response['location']
            warn "redirected to #{location}"
            fetch(URI(location), req, limit - 1)
          when Net::HTTPServerError
            raise Qa::ServiceUnavailable.new("#{uri.hostname} on port #{uri.port} is not responding.  Try again later.")
          when Net::HTTPNotFound
            raise Qa::TermNotFound.new("#{uri} Not Found - Term may not exist at LOD Authority.")
          else
            response.value
        end
      end

      def build_graph(content_type, raw_response)
        case content_type
          when 'application/rdf+xml'
            RDF::Graph.new.from_rdfxml raw_response
          when 'application/json'
            RDF::Graph.new.from_jsonld raw_response
          else
            raise Qa::UnsupportedFormat, "#{content_type} is unsupported. Supported types include rdf+xml and jsonld format."
        end
      end

      def parse_term_authority_response(graph,language)
        graph = filter_language(graph, language) unless language.nil?
        results = extract_selected_preds_for_term(graph)
        consolidated_results = consolidate_term_results(results)
        termhash = convert_term_to_json(consolidated_results).first
        predicates_hash = predicates_with_subject_uri(graph, termhash[:uri],language)
        termhash['predicates'] = predicates_hash unless predicates_hash.length <= 0
        termhash
      end

      def filter_language(graph,language)
        graph.each do |st|
          graph.delete(st) unless language.nil? || !st.object.respond_to?(:language) || st.object.language.nil? || st.object.language == language
        end
      end

      def extract_selected_preds_for_term(graph)
      # def extract_selected_preds_for_term(graph,language)
        label_pred_uri = predicate_uri(@auth_config['term']['results'],'label_predicate')
        raise Qa::InvalidConfiguration, "required label_predicate is missing in configuration for LOD authority #{auth_name}" if label_pred_uri.nil?
        altlabel_pred_uri = predicate_uri(@auth_config['term']['results'],'altlabel_predicate')
        id_pred_uri = predicate_uri(@auth_config['term']['results'],'id_predicate')
        narrower_pred_uri = predicate_uri(@auth_config['term']['results'],'narrower_predicate')
        broader_pred_uri = predicate_uri(@auth_config['term']['results'],'broader_predicate')
        sameas_pred_uri = predicate_uri(@auth_config['term']['results'],'sameas_predicate')

        RDF::Query.execute(graph) do
          pattern( [:uri, label_pred_uri, :label] )
          pattern( [:uri, altlabel_pred_uri, :altlabel], optional: true ) unless altlabel_pred_uri.nil?
          # pattern( [:uri, altlabel_pred_uri, :altlabel] ) unless altlabel_pred_uri.nil?
          pattern( [:uri, id_pred_uri, :id], optional: true ) unless id_pred_uri.nil?
          pattern( [:uri, narrower_pred_uri, :narrower], optional: true ) unless narrower_pred_uri.nil?
          pattern( [:uri, broader_pred_uri, :broader], optional: true ) unless broader_pred_uri.nil?
          pattern( [:uri, sameas_pred_uri, :sameas], optional: true ) unless sameas_pred_uri.nil?
        end
      end

      def consolidate_term_results(results)
        consolidated_results = {}
        results.each do |statement|
          stmt_hash = statement.to_hash
          uri = stmt_hash[:uri].to_s
          consolidated_hash = consolidated_results[uri] || {}

          if consolidated_hash.empty?
            consolidated_hash[:id] = uri
            id = stmt_hash[:id].to_s
            consolidated_hash[:id] = id unless id.nil? || id.length <= 0
          end
          consolidated_hash[:label] = object_value(stmt_hash,consolidated_hash,:label)
          altlabel = object_value(stmt_hash,consolidated_hash,:altlabel)
          narrower = object_value(stmt_hash,consolidated_hash,:narrower)
          broader = object_value(stmt_hash,consolidated_hash,:broader)
          sameas = object_value(stmt_hash,consolidated_hash,:sameas)

          consolidated_hash[:altlabel] = altlabel unless altlabel.nil?
          consolidated_hash[:narrower] = narrower unless narrower.nil?
          consolidated_hash[:broader] = broader unless broader.nil?
          consolidated_hash[:sameas] = sameas unless sameas.nil?
          consolidated_results[uri] = consolidated_hash
        end
        consolidated_results
      end

      def convert_term_to_json(consolidated_results)
        json_results = []
        consolidated_results.each do |uri,h|
          json_hash = { uri: uri, id: h[:id], label: h[:label] }
          json_hash[:altlabel] = h[:altlabel] unless h[:altlabel].nil?
          json_hash[:narrower] = h[:narrower] unless h[:narrower].nil?
          json_hash[:broader] = h[:broader] unless h[:broader].nil?
          json_hash[:sameas] = h[:sameas] unless h[:sameas].nil?
          json_results << json_hash
        end
        json_results
      end

      def predicates_with_subject_uri(graph, expected_uri, language)
        predicates_hash = {}
        graph.statements.each do |st|
          subj = st.subject.to_s
          next unless subj == expected_uri
          next unless language.nil? || !st.object.respond_to?(:language) || st.object.language.nil? || st.object.language == language
          pred = st.predicate.to_s
          obj  = st.object.to_s
          next if blank_node? obj
          if predicates_hash.key?(pred)
            objs = predicates_hash[pred]
            objs = [] unless objs.kind_of?(Array)
            objs << predicates_hash[pred] unless objs.length > 0
            objs << obj
            predicates_hash[pred] = objs
          else
            predicates_hash[pred] = [obj]
          end
        end
        predicates_hash
      end

      def parse_search_authority_response(graph,language)
        graph = filter_language(graph, language) unless language.nil?
        results = extract_uri_and_labels_from_search(graph,language)
        consolidated_results = consolidate_search_results(results)
        convert_search_to_json(consolidated_results)
      end

      def extract_uri_and_labels_from_search(graph,language)
        label_pred_uri = predicate_uri(@auth_config['search']['results'],'label_predicate')
        raise Qa::InvalidConfiguration, "required label_predicate is missing in configuration for LOD authority #{auth_name}" if label_pred_uri.nil?
        altlabel_pred_uri = predicate_uri(@auth_config['search']['results'],'altlabel_predicate')
        id_pred_uri = predicate_uri(@auth_config['search']['results'],'id_predicate')

        RDF::Query.execute(graph) do
          pattern( [:uri, label_pred_uri, :label] )
          pattern( [:uri, id_pred_uri, :id], optional: true ) unless id_pred_uri.nil?
          pattern( [:uri, altlabel_pred_uri, :altlabel], optional: true ) unless altlabel_pred_uri.nil?
        end
      end

      def consolidate_search_results(results)
        consolidated_results = {}
        results.each do |statement|
          stmt_hash = statement.to_hash
          uri = stmt_hash[:uri].to_s
          consolidated_hash = consolidated_results[uri] || {}

          if consolidated_hash.empty?
            consolidated_hash[:id] = uri
            id = stmt_hash[:id].to_s
            consolidated_hash[:id] = id unless id.nil? || id.length <= 0
          end
          consolidated_hash[:label] = object_value(stmt_hash,consolidated_hash,:label)
          consolidated_hash[:altlabel] = object_value(stmt_hash,consolidated_hash,:altlabel)
          consolidated_results[uri] = consolidated_hash
        end
        consolidated_results
      end

      def convert_search_to_json(consolidated_results)
        json_results = []
        consolidated_results.each do |uri,h|
          json_results << { uri: uri, id: h[:id], label: full_label(h[:label],h[:altlabel]) }
        end
        json_results
      end

      def predicate_uri(config, name)
        pred = config[name]
        pred_uri = nil
        pred_uri = RDF::URI(pred) unless pred.nil? || pred.length <= 0
        pred_uri
      end

      def object_value(stmt_hash, consolidated_hash, name)
        new_object_value = stmt_hash[name].to_s
        all_object_values = consolidated_hash[name] || []
        all_object_values << new_object_value unless new_object_value.nil? || new_object_value.length <= 0 || all_object_values.include?(new_object_value)
        all_object_values
      end

      def full_label(label=[], altlabel=[])
        lbl = "" if label.size <= 0
        lbl = label.first if label.size == 1
        lbl = '['+label.join(', ')+']' if label.size > 1
        lbl += " (#{altlabel.join(', ')})" unless altlabel.nil? || altlabel.length <= 0
        lbl = lbl.slice(0..95)+'...' if lbl.length > 98
        lbl
      end

      def term_language(language)
        return language.to_sym unless language.nil? || !(language.kind_of? String)
        lang = @auth_config['term']['language'] unless @auth_config['term'].nil? || !(@auth_config['term'].key? 'language')
        lang = lang.to_sym unless lang.nil?
        lang
      end

      def search_language(language)
        return language.to_sym unless language.nil? || !(language.kind_of? String)
        lang = @auth_config['search']['language'] unless @auth_config['search'].nil? || !(@auth_config['search'].key? 'language')
        lang = lang.to_sym unless lang.nil?
        lang
      end

      def blank_node? obj
        return true if obj.to_s.starts_with? "_:g"
        return false
      end
  end
end

