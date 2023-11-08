# used in initializer where autoload is unavailable, must be required here:
require 'qa/linked_data/authority_service'

module Qa
  class Engine < ::Rails::Engine
    isolate_namespace Qa

    config.before_configuration do
      # rubocop:disable Style/IfUnlessModifier

      # see https://github.com/fxn/zeitwerk#for_gem
      # Blacklight puts a generator into LOCAL APP lib/generators, so tell
      # zeitwerk to ignore the whole directory? If we're using zeitwerk
      #
      # See: https://github.com/cbeer/engine_cart/issues/117
      if Rails.try(:autoloaders).try(:main).respond_to?(:ignore)
        Rails.autoloaders.main.ignore(Rails.root.join('lib', 'generators'))
      end
    end
  end
end
