require "qa/engine"
require "active_record"
require "activerecord-import"

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
end
