module Qa
  module LinkedData
    module Config
      class SubauthMap
        # Defines the values that can be passed in as part of the qa url for the **subauth** parameter and maps them to
        # a value to use with the external authority.

        # @param config [Hash] key = name of the subauth used in the QA URL; value = name of the property to use with the external authority
        def initialize(config: {})
          @subauth_map = config
        end

        def subauth?(subauth)
          return false unless subauth.present?
          @subauth_map.key?(subauth.to_sym)
        end
        alias valid? subauth?

        def external_name(qa_subauth_name)
          return false unless valid?(qa_subauth_name)
          @subauth_map[qa_subauth_name.to_sym]
        end

        def external_name!(qa_subauth_name)
          raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data sub-authority #{qa_subauth_name}" unless qa_subauth_name.present? && valid?(qa_subauth_name)
          @subauth_map[qa_subauth_name.to_sym]
        end
      end
    end
  end
end
