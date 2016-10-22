module Qa::Authorities
  module Local
    class Registry
      def initialize
        @hash = {}
        yield self if block_given?
      end

      def keys
        @hash.keys
      end

      def instance_for(key)
        fetch(key).instance
      end

      def fetch(key)
        @hash.fetch(key)
      end

      def self.logger
        @logger ||= begin
          ::Rails.logger if defined? Rails && Rails.respond_to?(:logger)
        end
      end

      class << self
        attr_writer :logger
      end

      def add(subauthority, class_name)
        Registry.logger.debug "Registering Local QA authority: #{subauthority} - #{class_name}"
        @hash[subauthority] = RegistryEntry.new(subauthority, class_name)
      end

      class RegistryEntry
        def initialize(subauthority, class_name)
          @subauthority = subauthority
          @class_name = class_name
        end

        def klass
          @class_name.constantize
        end

        def instance
          klass.new(@subauthority)
        end
      end
    end
  end
end
