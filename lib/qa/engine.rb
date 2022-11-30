# used in initializer where autoload is unavailable, must be required here:
require 'qa/linked_data/authority_service'

module Qa
  class Engine < ::Rails::Engine
    isolate_namespace Qa
  end
end
