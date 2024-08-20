require "qa/engine"
require "active_record"
require "activerecord-import"
require "qa/authority_wrapper"

module Qa
  extend ActiveSupport::Autoload

  autoload :Authorities
  autoload :Configuration
  autoload :Services

  # @api public
  #
  # Exposes the Questioning Authority configuration
  #
  # @yield [Qa::Configuration] if a block is passed
  # @return [Qa::Configuration]
  # @see Qa::Configuration for configuration options
  def self.config(&block)
    @config ||= Qa::Configuration.new

    yield @config if block

    @config
  end

  def self.deprecation_warning(in_msg: nil, msg:)
    return if Rails.env == 'test'
    in_msg = in_msg.present? ? "In #{in_msg}, " : ''
    warn "[DEPRECATED] #{in_msg}#{msg}  It will be removed in the next major release."
  end

  # Raised when the authority is not valid
  class InvalidAuthorityError < RuntimeError
    def initialize(authority_class)
      super "Unable to initialize authority #{authority_class}"
    end
  end

  # Raised when the configuration directory for local authorities doesn't exist
  class ConfigDirectoryNotFound < StandardError; end

  # Raised when a subauthority is not passed into an authority
  class MissingSubAuthority < ArgumentError; end

  # Raised when a subauthority is not valid
  class InvalidSubAuthority < ArgumentError; end

  # Raised when a request is made to a non-configured linked data authority
  class InvalidLinkedDataAuthority < ArgumentError; end

  # Raised when a response is in an unsupported format
  class UnsupportedFormat < ArgumentError; end

  # Raised when a configuration parameter is incorrect or is required and missing
  class InvalidConfiguration < ArgumentError; end

  # Raised when a request is made for an unsupported action (e.g. :search, :term are supported)
  class UnsupportedAction < ArgumentError; end

  # Raised when a linked data request to a server returns a 503 error
  class ServiceUnavailable < ArgumentError; end

  # Raised when a linked data request to a server returns a 500 error
  class ServiceError < ArgumentError; end

  # Raised when the server returns 404 for a find term request
  class TermNotFound < ArgumentError; end

  # Raised when a required mapping parameter is missing while building an IRI Template
  module IriTemplate
    class MissingParameter < StandardError; end
  end

  # Raised when data is returned but cannot be normalized
  class DataNormalizationError < StandardError; end

  # @api public
  # @since 5.11.0
  #
  # @param vocab [String]
  # @param subauthority [String]
  # @param context [#params, #search_header, #fetch_header]
  # @param try_linked_data_config [Boolean] when true attempt to check for a linked data authority;
  #        this is included as an option to help preserve error messaging from the 5.10.0 branch.
  #        Unless you want to mirror the error messages of `Qa::TermsController#init_authority` then
  #        use the default value.
  #
  # @note :try_linked_data_config is included to preserve error message text; something which is
  #       extensively tested in this gem.
  #
  # @return [#search, #find] an authority that will respond to #search and #find; and in some cases
  #         #fetch.  This is provided as a means of normalizing how we initialize an authority.
  #         And to provide a means to request an authority both within a controller request cycle as
  #         well as outside of that cycle.
  def self.authority_for(vocab:, context:, subauthority: nil, try_linked_data_config: true)
    authority = build_authority_for(vocab: vocab,
                                    subauthority: subauthority,
                                    try_linked_data_config: try_linked_data_config)
    AuthorityWrapper.new(authority: authority, subauthority: subauthority, context: context)
  end

  # @api private
  def self.build_authority_for(vocab:, subauthority: nil, try_linked_data_config: true)
    authority_constant_name = "Qa::Authorities::#{vocab.to_s.camelcase}"
    authority_constant = authority_constant_name.safe_constantize
    if authority_constant.nil?
      return Qa::Authorities::LinkedData::GenericAuthority.new(vocab.upcase.to_sym) if try_linked_data_config

      raise InvalidAuthorityError, authority_constant_name
    end

    return authority_constant.new if authority_constant.is_a?(Class)
    return authority_constant.subauthority_for(subauthority) if subauthority.present?

    raise Qa::MissingSubAuthority, "No sub-authority provided"
  end
  private_class_method :build_authority_for
end
