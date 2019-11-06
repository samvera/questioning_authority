# Service to determine which language to use for sorting and filtering.
module Qa
  module LinkedData
    class RequestHeaderService
      attr_reader :request, :params

      # @param request [HttpRequest] request from controller
      # @param params [Hash] attribute-value pairs holding the request parameters
      # @option language [Symbol] language used to select literals when multi-language is supported (e.g. :en, :fr, etc.)
      # @option replacements [Hash] replacement values with { pattern_name (defined in YAML config) => value }
      # @option subauth [String] the subauthority to query
      # @option performance_data [Boolean] true if include_performance_data should be returned with the results; otherwise, false (default: false)
      # @option context [Boolean] true if context should be returned with the results; otherwise, false (default: false) (search only)
      # @option format [String] return data in this format (fetch only)
      def initialize(request, params)
        @request = request
        @params = params
      end

      # Construct request parameters to pass to search_query (linked data module).
      # @returns [Hash] parsed out attribute-value pairs that are required for the search query
      # @see Qa::Authorities::LinkedData::SearchQuery
      def search_header
        header = {}
        header[:subauthority] = params.fetch(:subauthority, nil)
        header[:language] = language
        header[:context] = context?
        header[:performance_data] = performance_data?
        header[:replacements] = replacements
        header
      end

      # Construct request parameters to pass to fetching a term (linked data module).
      # @returns [Hash] parsed out attribute-value pairs that are required for the term fetch.
      # @see Qa::Authorities::LinkedData::FindTerm
      def fetch_header
        header = {}
        header[:subauthority] = params.fetch(:subauthority, nil)
        header[:language] = language
        header[:format] = format
        header[:performance_data] = performance_data?
        header[:replacements] = replacements
        header
      end

      # @returns [String] the response header content type based on requested format
      def content_type_for_format
        case format
        when 'jsonld'
          'application/ld+json'
        when 'n3'
          'text/n3'
        when 'ntriples'
          'application/n-triples'
        else
          'application/json'
        end
      end

      private

        def language
          request_language = request.env['HTTP_ACCEPT_LANGUAGE']
          request_language = request_language.scan(/^[a-z]{2}/).first if request_language.present?
          lang = params[:lang] || request_language
          lang.present? ? Array(lang) : nil
        end

        def context?
          context = params.fetch(:context, 'false')
          context.casecmp?('true')
        end

        def performance_data?
          performance_data = params.fetch(:performance_data, 'false')
          performance_data.casecmp?('true')
        end

        def replacements
          params.reject do |k, _v|
            ['q', 'vocab', 'controller', 'action', 'subauthority', 'lang', 'id',
             'context', 'performance_data', 'response_header', 'format'].include?(k)
          end
        end

        def format
          f = params.fetch(:format, 'json').downcase
          ['jsonld', 'n3', 'ntriples'].include?(f) ? f : 'json'
        end
    end
  end
end
