module Qa
  # Provide pagination processing that authority modules can use to respond to
  # requests for paginated results.
  class PaginationService # rubocop:disable Metrics/ClassLength
    # Default page_limit to use if not passed in with the request.
    DEFAULT_PAGE_LIMIT = 10

    # Error code for page_limit and page_offset when the value is not an integer.
    ERROR_NOT_INTEGER = 901
    # Error code for page_limit and page_offset when the value is below the acceptable range (e.g. < 1).
    ERROR_OUT_OF_RANGE_TOO_SMALL = 902
    # Error code for page_offset when the value is above the acceptable range (e.g. > total_num_found).
    ERROR_OUT_OF_RANGE_TOO_LARGE = 903

    # @param request [ActionDispatch::Request] The request from the controller.
    #   To support pagination, it's params need to respond to:
    #   * #page_offset [Integer] - the offset into the results for the start of the page (counts from 1; default: 1)
    #   * #page_limit [Integer] - the max number of records to return in a page
    #     * if not paginating, defaults to: all
    #     * if `default_to_all_terms == true` AND neither page_offset nor page_limit are set, defaults to: all
    #     * else defaults to: DEFAULT_PAGE_LIMIT
    # @param results [Array<Hash>] results of a search query as processed by the authority module.
    # @param format [String] - if present, supported values are [:json | :jsonapi]
    #     * when :json, the response is an array of results
    #     * when :json-api, the response follows the JSON API specification
    #
    # @see https://jsonapi.org/format/#fetching-pagination Pagination section of JSON API specification
    # @see https://jsonapi.org/examples/#pagination JSON API example pagination
    def initialize(request:, results:, format: :json)
      @request = request
      @results = results
      @requested_format = format
      @page_offset_error = false
      @page_limit_error = false
    end

    # @return json results, optionally limited to requested page and optionally
    #     formatted according to the JSON-API standard.  The default is to return
    #     just the results for backward compatibility.  See examples.
    #
    # @example json without pagination (backward compatible)
    #   # request: q=term
    #   # response: format=json, no pagination, all results
    #   [
    #     { "id": "1", "label": "term 1" },
    #     { "id": "2", "label": "term 2" },
    #     ...
    #     { "id": "28", "label": "term 28" }
    #   ]
    #
    # @example json with pagination
    #   # request: q=term, page_offset=3, page_limit=2
    #   # response: format=json, paginated, results 3..4
    #   [
    #     { "id": "3", "label": "term 3" },
    #     { "id": "4", "label": "term 4" }
    #   ]
    #
    # @example json-api with pagination using default page_offset and page_limit
    #   # request: q=term, format=json-api
    #   # response: format=json-api, paginated, results 1..8
    #   {
    #     "data": [
    #       { "id": "1", "label": "term 1" },
    #       { "id": "2", "label": "term 2" },
    #       ...
    #       { "id": "8", "label": "term 8" }
    #     ],
    #     "meta": {
    #       "page": {
    #         "page_offset": "1",
    #         "page_limit": "8",
    #         "actual_page_size": "8",
    #         "total_num_found": "28",
    #       }
    #     }
    #     "links": {
    #       "self_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=8&page_offset=1",
    #       "first_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=8&page_offset=1",
    #       "prev_url": nil,
    #       "next_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=8&page_offset=9",
    #       "last_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=8&page_offset=25"
    #     }
    #   }
    #
    # @example json-api with pagination for page_offset=7 and page_limit=2
    #   # request: q=term, format=json-api, page_offset=7, page_limit=2
    #   # response: format=json, paginated, results 7..8
    #   {
    #     "data": [
    #       { "id": "7", "label": "term 7" },
    #       { "id": "8", "label": "term 8" }
    #     ],
    #     "meta": {
    #       "page": {
    #         "page_offset": "7",
    #         "page_limit": "2",
    #         "actual_page_size": "2",
    #         "total_num_found": "28",
    #       }
    #     }
    #     "links": {
    #       "self_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=2&page_offset=7",
    #       "first_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=2&page_offset=1",
    #       "prev_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=2&page_offset=5",
    #       "next_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=2&page_offset=9",
    #       "last_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=2&page_offset=27"
    #     }
    #   }
    #
    # @example json-api with page_offset and page_limit errors
    #   # request: q=term, format=json-api, page_offset=0, page_limit=-1
    #   # response: format=json-api, paginated, no results, errors
    #   {
    #     "data": [],
    #     "meta": {
    #       "page": {
    #         "page_offset": "0",
    #         "page_limit": "-1",
    #         "actual_page_size": nil,
    #         "total_num_found": "28",
    #       }
    #     }
    #     "links": {
    #       "self_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=-1&page_offset=0",
    #       "first_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=8&page_offset=1",
    #       "prev_url": nil,
    #       "next_url": nil,
    #       "last_url": "http://example.com/qa/search/local/states?q=new&format=json-api&page_limit=8&page_offset=25"
    #     }
    #     "errors": [
    #       {
    #         "status" => "200",
    #         "source" => { "page_offset" => "0" },
    #         "title" => "Page Offset Out of Range",
    #         "detail" => "Offset 0 < 1 (first result).  Returning empty results."
    #       },
    #       {
    #         "status" => "200",
    #         "source" => { "page_limit" => "-1" },
    #         "title" => "Page Limit Out of Range",
    #         "detail" => "Page limit -1 < 1 (minimum limit).  Returning empty results."
    #
    #       }
    #     ]
    #   }
    #
    # @see DEFAULT_PAGE_LIMIT
    # @see ERROR_NOT_INTEGER
    # @see ERROR_OUT_OF_RANGE_TOO_SMALL
    # @see ERROR_OUT_OF_RANGE_TOO_LARGE
    def build_response
      json_api? ? build_json_api_response : build_json_response
    end

    private

      def errors?
        page_offset_error? || page_limit_error?
      end

      def page_offset_error?
        page_offset
        @page_offset_error
      end

      def page_limit_error?
        page_limit
        @page_limit_error
      end

      # @return just the data as a JSON array
      def build_json_response
        errors? ? [] : build_data
      end

      # @return pages of results following the JSON API standard
      def build_json_api_response
        errors? ? build_json_api_response_with_errors : build_json_api_response_without_errors
      end

      def build_json_api_response_without_errors
        {
          "data" => build_data,
          "meta" => build_meta,
          "links" => build_links
        }
      end

      def build_json_api_response_with_errors
        {
          "data" => [],
          "meta" => build_meta,
          "links" => build_links_when_errors,
          "errors" => build_errors
        }
      end

      def build_data
        @results[start_index..last_index]
      end

      def build_meta
        meta = {}
        meta['page_offset'] = page_offset_error? ? @requested_page_offset.to_s : page_offset.to_s
        meta['page_limit'] = page_limit_error? ? @requested_page_limit.to_s : page_limit.to_s
        meta['actual_page_size'] = errors? ? "0" : actual_page_size.to_s
        meta['total_num_found'] = total_num_found.to_s
        { "page" => meta }
      end

      def build_links
        links = {}
        links['self'] = self_link
        links['first'] = first_link
        links['prev'] = prev_link
        links['next'] = next_link
        links['last'] = last_link
        links
      end

      def build_links_when_errors
        links = {}
        links['self'] = "#{request_base_url}#{request_path}?#{request_query_string}"
        links['first'] = first_link
        links['prev'] = nil
        links['next'] = nil
        links['last'] = last_link
        links
      end

      def build_errors
        errors = []
        errors << build_page_offset_error if page_offset_error?
        errors << build_page_limit_error if page_limit_error?
        errors
      end

      def build_page_offset_error
        case @page_offset_error
        when ERROR_NOT_INTEGER
          build_page_offset_not_integer
        when ERROR_OUT_OF_RANGE_TOO_LARGE
          build_page_offset_too_large
        when ERROR_OUT_OF_RANGE_TOO_SMALL
          build_page_offset_too_small
        end
      end

      def build_page_limit_error
        case @page_limit_error
        when ERROR_NOT_INTEGER
          build_page_limit_not_integer
        when ERROR_OUT_OF_RANGE_TOO_SMALL
          build_page_limit_too_small
        end
      end

      def build_page_offset_not_integer
        {
          "status" => "200",
          "source" => { "page_offset" => @requested_page_offset },
          "title" => "Page Offset Invalid",
          "detail" => "Page offset #{@requested_page_offset} is not an Integer.  Returning empty results."
        }
      end

      def build_page_offset_too_large
        {
          "status" => "200",
          "source" => { "page_offset" => @requested_page_offset },
          "title" => "Page Offset Out of Range",
          "detail" => "Page offset #{@requested_page_offset} > #{total_num_found} (total number of results).  Returning empty results."
        }
      end

      def build_page_offset_too_small
        {
          "status" => "200",
          "source" => { "page_offset" => page_offset.to_s },
          "title" => "Page Offset Out of Range",
          "detail" => "Page offset #{@requested_page_offset} < 1 (first result).  Returning empty results."
        }
      end

      def build_page_limit_not_integer
        {
          "status" => "200",
          "source" => { "page_limit" => @requested_page_limit },
          "title" => "Page Limit Invalid",
          "detail" => "Page limit #{@requested_page_limit} is not an Integer.  Returning empty results."
        }
      end

      def build_page_limit_too_small
        {
          "status" => "200",
          "source" => { "page_limit" => @requested_page_limit.to_s },
          "title" => "Page Limit Out of Range",
          "detail" => "Page limit #{@requested_page_limit} < 1 (minimum limit).  Returning empty results."
        }
      end

      def request_params
        @request_params ||= @request.params
      end

      def request_query_params
        @request_query_params ||= @request.query_parameters
      end

      def request_query_string
        @request_query_string ||= @request.query_string
      end

      def request_base_url
        @request_base_url ||= @request.base_url
      end

      def request_path
        @request_path ||= @request.path
      end

      # @return [Boolean] true if results should be formatted according to JSON API standard
      def json_api?
        format == :jsonapi
      end

      # @param [Symbol] The requested format of the response (default=:json)
      # @note Supported formats include [:json | :json-api].  For backward compatibility,
      #   it defaults to :json.
      def format
        return @format if @format.present?
        return @format = @requested_format if [:json, :jsonapi].include? @requested_format
        Rails.logger.warn("Format '#{@requested_format}' is not a valid format for search.  Supported formats are [:json, :jsonapi].  Defaulting to :json.")
        @format = :json
      end

      # @return [Integer] The first record to include in the response data. (default=1).
      # @note The first record may be out of range (i.e., < 1 or > total_num_of_results),
      # but it will always be numeric, defaulting to 1 if not specified or not an Integer.
      def page_offset
        return @page_offset if @page_offset.present?
        return @page_offset = 1 unless page_offset_specified?
        @page_offset = validated_request_page_offset || 1
      end

      # @return [Boolean] true if the request specifies the page offset; otherwise, false
      def page_offset_specified?
        request_params.keys.include?("page_offset") || request_params.keys.include?("startRecord")
      end

      # @return [Integer] The page offset as specified in the request_params, nil if invalid.
      # @note The page offset can be specified with page_offset (preferred) or
      #       startRecord (deprecated, supported for backward compatibility with
      #       linked_data module pagination).
      def requested_page_offset
        return @requested_page_offset if @requested_page_offset.present?
        @requested_page_offset = (request_params['page_offset'] || request_params['startRecord'])
      end

      # @return [Integer] The first record to include in the response data as
      #     requested as long as it is an Integer; otherwise, returns nil.
      def validated_request_page_offset
        @page_offset_error = false
        offset = Integer(requested_page_offset)
        return offset if offset == 1
        @page_offset_error = ERROR_OUT_OF_RANGE_TOO_SMALL if offset < 1
        @page_offset_error = ERROR_OUT_OF_RANGE_TOO_LARGE if offset > total_num_found
        offset
      rescue
        @page_offset_error = ERROR_NOT_INTEGER
        nil
      end

      # @return [Integer] The requested maximum number of results to return (default=DEFAULT_PAGE_LIMIT | ALL)
      # @see #default_page_limit
      # @see DEFAULT_PAGE_LIMIT
      def page_limit
        return @page_limit if @page_limit.present?
        return @page_limit = default_page_limit unless page_limit_specified?
        @page_limit = validated_request_page_limit || default_page_limit
      end

      # @return [Boolean] true if the request specifies the page limit; otherwise, false
      def page_limit_specified?
        request_params.keys.include?("page_limit") || request_params.keys.include?("maxRecords")
      end

      # @return [Integer] The max number of records for a page as specified in the request_params.
      # @note The page size limit can be specified with page_limit (preferred) or
      #       maxRecords (deprecated, supported for backward compatibility with
      #       linked_data module pagination).
      def requested_page_limit
        return @requested_page_limit if @requested_page_limit.present?
        @requested_page_limit ||= (request_params['page_limit'] || request_params['maxRecords'])
      end

      # @return [Integer] The max number of records to include in response data as
      #     requested as long as it is a positive Integer; otherwise, returns nil.
      def validated_request_page_limit
        @page_limit_error = false
        limit = Integer(requested_page_limit)
        @page_limit_error = ERROR_OUT_OF_RANGE_TOO_SMALL if limit < 1
        limit.positive? ? limit : nil
      rescue
        @page_limit_error = ERROR_NOT_INTEGER
        nil
      end

      # @return [Integer] The default to use when page_limit isn't specified.
      # @note To maintain backward compatibility, the limit will be all results
      #   if format is json and neither page_limit nor page_offset were specified.
      def default_page_limit
        return total_num_found unless json_api? || page_offset_specified? || page_limit_specified?
        DEFAULT_PAGE_LIMIT
      end

      # @return [Integer] the index into the terms Array for the first record to
      #     include in the page data
      # @note page_offset begins counting at 1 and the Array index begins at 0.
      def start_index
        @start_index ||= page_offset - 1
      end

      # @return [Integer] the index into the terms Array for the last record to
      #     include in the page data
      def last_index
        return @last_index if @last_index.present?
        return @last_index = start_index if start_index >= last_possible_index
        last_index = start_index + page_limit - 1
        @last_index = last_index <= last_possible_index ? last_index : last_possible_index
      end

      # @return [Integer] the index for the last term in the Array
      def last_possible_index
        total_num_found - 1
      end

      # @return [Integer] actual number of results in the returned page of results;
      #     0 if request is out of range
      def actual_page_size
        @actual_page_size ||= start_index <= last_possible_index ? last_index - start_index + 1 : 0
      end

      # @return [Integer] total number of terms matching the search query
      def total_num_found
        @results.length
      end

      # @return the URL to current page of results
      def self_link
        url_with(page_offset: page_offset)
      end

      # @return the URL to the first page of results
      def first_link
        url_with(page_offset: 1)
      end

      # @return the URL to the last page of results
      def last_link
        last_start = (total_num_found / page_limit) * page_limit + 1
        last_start -= page_limit if last_start > total_num_found
        last_start = 1 if last_start < 1
        url_with(page_offset: last_start)
      end

      # @return the URL to the next page of results; nil if on last page
      def next_link
        next_start = page_offset + page_limit
        next_start <= total_num_found ? url_with(page_offset: next_start) : nil
      end

      # @return the URL to the previous page of results; nil if on first page
      def prev_link
        return if page_offset == 1
        prev_start = page_offset - page_limit
        prev_start >= 1 ? url_with(page_offset: prev_start) : url_with(page_offset: 1)
      end

      # @return the original URL without the parameters
      def url_without_parameters
        URI.parse(request_base_url + request_path)
      end

      # Generate a URL based off the original URL and parameter values with page_offset
      # updated based on the passed in value.
      # @param page_offset [Integer] the value to use for page_offset
      # @return [String] a full URL with the updated page_offset
      def url_with(page_offset:)
        updated_params = update_parameters(page_offset)

        uri = url_without_parameters
        uri.query = URI.encode_www_form(updated_params)
        uri.to_s
      end

      # @param page_offset [Integer] the value to use for page_offset
      # @return [Hash] parameter key-value pairs formatted for the URL using
      #     the preferred parameter name and updated page_offset value
      def update_parameters(page_offset)
        updated_params = {}
        request_query_params.each do |k, v|
          next if ['page_offset', 'page_limit'].include? k
          updated_params[k] = v
        end
        updated_params['page_limit'] = page_limit
        updated_params['page_offset'] = page_offset
        updated_params
      end
  end
end
