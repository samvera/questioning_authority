module Qa::Authorities
  # A wrapper around the FAST api for use with questioning_authority
  # API documentation:
  # http://www.oclc.org/developer/develop/web-services/fast-api/assign-fast.en.html
  class AssignFast::GenericAuthority < Base
    attr_reader :subauthority

    def initialize(subauthority)
      super()
      @subauthority = subauthority
    end

    include WebServiceBase

    require 'qa/authorities/assign_fast/space_fix_encoder'
    # FAST requires spaces to be encoded as %20 and will not accept + which is Faraday's default encoding
    def response(url)
      space_fix_encoder = AssignFast::SpaceFixEncoder.new
      Faraday.get(url) do |req|
        req.options.params_encoder = space_fix_encoder
        req.headers['Accept'] = 'application/json'
        unless connection_timeout_in_seconds.nil?
          req.options.timeout = connection_timeout_in_seconds
        end
      end
    end

    def connection_timeout_in_seconds
      @connection_timeout_in_seconds ||= Qa.config.linked_data_authority_configs.
        dig(:OCLC_FAST, :search, :connection, :timeout).to_i
    end

    # Search the FAST api
    #
    # @param [String] the query
    # @return json results
    def search(q)
      url = build_query_url q
      begin
        raw_response = json(url)
      rescue JSON::ParserError
        Rails.logger.info "Could not parse response as JSON. Request url: #{url}"
        return []
      end
      parse_authority_response(raw_response)
    end

    # Build a FAST API url
    #
    # @param [String] the query
    # @return [String] the url
    def build_query_url(q)
      escaped_query = clean_query_string q
      index = AssignFast.index_for_authority(subauthority)
      return_data = "#{index}%2Cidroot%2Cauth%2Ctype"
      num_rows = 20 # max allowed by the API

      # sort=usage+desc is not documented by OCLC but seems necessary to get the sort
      # we formerly got without specifying, that is most useful in our use case.
      "http://fast.oclc.org/searchfast/fastsuggest?&query=#{escaped_query}&queryIndex=#{index}&queryReturn=#{return_data}&suggest=autoSubject&rows=#{num_rows}&sort=usage+desc"
    end

    private

      # Removes characters from the query string that are not tolerated by the API
      #   See oclc sample code at
      #   http://experimental.worldcat.org/fast/assignfast/js/assignFASTComplete.js
      def clean_query_string(q)
        ERB::Util.url_encode(q.gsub(/-|\(|\)|:/, ""))
      end

      def parse_authority_response(raw_response)
        raw_response['response']['docs'].map do |doc|
          index = AssignFast.index_for_authority(subauthority)
          term = doc[index].first
          term += ' USE ' + doc['auth'] if doc['type'] == 'alt'
          { id: doc['idroot'], label: term, value: doc['auth'] }
        end
      end
  end
end
