# Service to construct a request header that includes optional attributes for search and fetch requests.
module Qa
  module LinkedData
    class RequestHeaderService
      attr_reader :request, :params

      # @param request [HttpRequest] request from controller
      # @param params [Hash] attribute-value pairs holding the request parameters
      # @option subauthority [String] the subauthority to query
      # @option lang [Symbol] language used to select literals when multi-language is supported (e.g. :en, :fr, etc.)
      # @option performance_data [Boolean] true if include_performance_data should be returned with the results; otherwise, false (default: false)
      # @option context [Boolean] true if context should be returned with the results; otherwise, false (default: false) (search only)
      # @option format [String] return data in this format (fetch only)
      # @note params may have additional attribute-value pairs that are passed through via replacements (only configured replacements are used)
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
        header[:user_language] = user_language
        header[:performance_data] = performance_data?
        header[:context] = context?
        header[:replacements] = replacements
        header
      end

      # Construct request parameters to pass to fetching a term (linked data module).
      # @returns [Hash] parsed out attribute-value pairs that are required for the term fetch.
      # @see Qa::Authorities::LinkedData::FindTerm
      def fetch_header
        header = {}
        header[:subauthority] = params.fetch(:subauthority, nil)
        header[:user_language] = user_language
        header[:performance_data] = performance_data?
        header[:format] = format
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

        # filter literals in results to this language
        def user_language
          request_language = request.env['HTTP_ACCEPT_LANGUAGE']
          request_language = request_language.scan(/^[a-z]{2}/).first if request_language.present?
          lang = params[:lang] || request_language
          lang.present? ? Array(lang) : nil
        end

        # include extended context in the results if true (applies to search only)
        def context?
          context = params.fetch(:context, 'false')
          context.casecmp?('true')
        end

        # include performance data in the results if true
        def performance_data?
          performance_data = params.fetch(:performance_data, 'false')
          performance_data.casecmp?('true')
        end

        # any params not specifically handled are passed through via replacements
        def replacements
          params.reject do |k, _v|
            ['q', 'vocab', 'controller', 'action', 'subauthority', 'lang', 'id',
             'context', 'performance_data', 'response_header', 'format'].include?(k)
          end
        end

        # results are returned in the format (applies to fetch only)
        def format
          f = params.fetch(:format, 'json').downcase
          ['jsonld', 'n3', 'ntriples'].include?(f) ? f : 'json'
        end
    end
  end
end
