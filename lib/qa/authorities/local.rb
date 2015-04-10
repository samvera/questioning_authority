module Qa::Authorities
  module Local
    extend AuthorityWithSubAuthority
    extend Qa::Authorities::LocalSubauthority
    require 'qa/authorities/local/file_based_authority'


    def self.subauthority_for(sub_authority)
      validate_sub_authority!(sub_authority)
      registry.instance_for(sub_authority)
    end

    def self.registry
      @registry ||= begin
        Registry.new do |reg|
          register_defaults(reg)
        end
      end
    end


    def self.register_subauthority(sub_authority, class_name)
      registry.add(sub_authority, class_name)
    end

    def self.sub_authorities
      registry.keys
    end

    private
      def self.register_defaults(reg)
        names.each do |name|
          reg.add(name, 'Qa::Authorities::Local::FileBasedAuthority')
        end
      end

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
          ::Rails.logger if defined? Rails and Rails.respond_to? :logger
        end
      end

      def self.logger= logger
        @logger = logger
      end

      def add(sub_authority, class_name)
        Registry.logger.debug "Registering Local QA authority: #{sub_authority} - #{class_name}"
        @hash[sub_authority] = RegistryEntry.new(sub_authority, class_name)
      end


      class RegistryEntry
        def initialize(sub_authority, class_name)
          @sub_authority, @class_name = sub_authority, class_name
        end

        def klass
          @class_name.constantize
        end

        def instance
          klass.new(@sub_authority)
        end
      end
    end
  end
end
