# Registry of linked data authority configurations.
module Qa
  module LinkedData
    class AuthorityRegistryService
      @registry = {}

      # List registered authorities.
      # @returns [Array<String>] registered authority names
      def self.list
        @registry.keys
      end

      # Fetch an authority configuration.
      # @param [String] the name of the authority to fetch
      # @returns [Qa::LinkedData::Config::AuthorityConfig] the requested authority configuration if registered; otherwise, nil
      def self.retrieve_or_create(authority_name)
        return @registry[authority_name] if registered?(authority_name)
        auth_config = Qa::LinkedData::Config::AuthorityConfig.new(authority_name)
        add(auth_config)
        auth_config
      end

      # Fetch an authority configuration.
      # @param [String] the name of the authority to fetch
      # @returns [Qa::LinkedData::Config::AuthorityConfig] the requested authority configuration if registered; otherwise, nil
      def self.retrieve(authority_name)
        return nil unless registered?(authority_name)
        @registry[authority_name]
      end

      # Fetch an authority configuration.
      # @param [String] the name of the authority to fetch
      # @returns [Qa::LinkedData::Config::AuthorityConfig] the requested authority configuration if registered; otherwise, raises an exception
      def self.retrieve!(authority_name)
        unless Qa::LinkedData::AuthorityRegistryService.registered?(authority_name)
          raise Qa::InvalidLinkedDataAuthority, "Authority (#{authority_name}) is not registered.  Place configuration in config/authorities/linked_data and restart server."
        end
        @registry[authority_name]
      end

      # Register an authority.
      # @param [Qa::LinkedData::Config::AuthorityConfig] the authority configuration to register
      def self.add(authority_config)
        return if registered?(authority_config.authority_name) # don't register twice
        @registry[authority_config.authority_name] = authority_config
      end

      # Remove an authority from the registry.
      # @param [String] the name of the authority configuration to remove
      def self.remove(authority_name)
        return unless registered?(authority_name)
        @registry.delete(authority_name)
      end

      # Update an existing registration of an authority.
      # @param [Qa::LinkedData::Config::AuthorityRegistry] the authority configuration to register
      def self.update(authority_config)
        remove(authority_config.authority_name)
        add(authority_config)
      end

      # Does the registry hold an authority?
      # @param [String] the name of the authority to check
      # @return [Boolean] true if the authority is already registered; otherwise, false
      def self.registered?(authority_name)
        @registry.key?(authority_name)
      end

      def self.empty
        @registry = {}
      end
    end
  end
end
