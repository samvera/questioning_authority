require "qa/engine"
require "active_record"
require "activerecord-import"

module Qa
  extend ActiveSupport::Autoload

  autoload :Authorities

  # Raised when the configuration directory for local authorities doesn't exist
  class ConfigDirectoryNotFound < StandardError; end

  # Raised when a subauthority is not passed into an authority
  class MissingSubAuthority < ArgumentError; end

  # Raised when a subauthority is not valid
  class InvalidSubAuthority < ArgumentError; end
end
