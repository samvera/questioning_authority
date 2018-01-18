# Provide access to subauthorities map for linked data authority configurations.
module Qa
  module LinkedData
    module Config
      class SubauthMap
        # Defines the values that can be passed in as part of the qa url for the **subauth** parameter and maps them to
        # a value to use with the external authority.
        # @param config [Hash] key = name of the subauth used in the QA URL; value = name of the property to use with the external authority
        def initialize(config = {})
          @subauth_map = config
        end

        # Does this sub-authority map have the specified subauth_key defined?
        # @param [Symbol] subauth_key into the sub-authority map
        # @return [Boolean] true if subauth_key is in the map; otherwise, false
        def subauth?(subauth_key)
          return false unless subauth_key.present?
          @subauth_map.key?(subauth_key.to_sym)
        end
        alias valid? subauth?

        # Retrieve from the map the name of the sub-authority as required by the external authority.
        # @param [Symbol] subauth_key into the sub-authority map
        # @return [String] external authorities name for the sub-authority if it is defined; otherwise, return empty string
        def external_name(subauth_key)
          return false unless valid?(subauth_key)
          @subauth_map[subauth_key.to_sym]
        end

        # Retrieve from the map the name of the sub-authority as required by the external authority.
        # @param [Symbol] subauth_key into the sub-authority map
        # @return [String] external authorities name for the sub-authority if it is defined; otherwise, raise exception
        def external_name!(subauth_key)
          raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data sub-authority #{subauth_key}" unless valid?(subauth_key)
          @subauth_map[subauth_key.to_sym]
        end
      end
    end
  end
end
