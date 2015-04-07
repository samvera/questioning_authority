require "qa/engine"
require "active_record"
require "activerecord-import"

module Qa
  extend ActiveSupport::Autoload

  autoload :Authorities

  # Raised when the configuration directory for local authorities doesn't exist
  class ConfigDirectoryNotFound < StandardError; end
end
