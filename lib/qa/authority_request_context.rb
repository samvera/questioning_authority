module Qa
  # @note THIS IS NOT TESTED NOR EXERCISED CODE IT IS PROVIDED AS CONJECTURE.  FUTURE CHANGES MIGHT
  #       BUILD AND REFACTOR UPON THIS.
  #
  # @api private
  # @abstract
  #
  # This class is responsible for exposing methods that are required by both linked data and
  # non-linked data authorities.  As of v5.10.0, those three methods are: params, search_header,
  # fetch_header.  Those are the methods that are used in {Qa::LinkedData::RequestHeaderService} and
  # in {Qa::Authorities::Discogs::GenericAuthority}.
  #
  # The intention is to provide a class that can behave like a controller object without being that
  # entire controller object.
  #
  # @see Qa::LinkedData::RequestHeaderService
  # @see Qa::Authorities::Discogs::GenericAuthority
  class AuthorityRequestContext
    def self.fallback
      new
    end

    def initialize(params: {}, headers: {}, **kwargs)
      @params = params
      @headers = headers
      (SEARCH_HEADER_KEYS + FETCH_HEADER_KEYS).uniq.each do |key|
        send("#{key}=", kwargs[key]) if kwargs.key?(key)
      end
    end

    SEARCH_HEADER_KEYS = %i[request request_id subauthority user_language performance_data context response_header replacements].freeze
    FETCH_HEADER_KEYS = %i[request request_id subauthority user_language performance_data format response_header replacements].freeze

    attr_accessor :params, :headers
    attr_accessor(*(SEARCH_HEADER_KEYS + FETCH_HEADER_KEYS).uniq)

    def search_header
      SEARCH_HEADER_KEYS.each_with_object(headers.deep_dup) do |key, header|
        header[key] = send(key).present?
      end.compact
    end

    def fetch_header
      FETCH_HEADER_KEYS.each_with_object(headers.deep_dup) do |key, header|
        header[key] = send(key).present?
      end.compact
    end
  end
end
