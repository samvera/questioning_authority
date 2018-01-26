# Provide service for constructing the external access URL for an authority.
module Qa
  module LinkedData
    class AuthorityUrlService
      def self.build_url(authority:, subauthority: nil, action:, action_request:, substitutions:)
        auth_config = Qa::LinkedData::AuthorityRegistryService.retrieve!(authority)
        action_config = auth_config.action_config!(action)
        indifferent_substitutions = HashWithIndifferentAccess.new(substitutions)
        indifferent_substitutions[action_config.action_request_variable] = action_request
        indifferent_substitutions[auth_config.subauth_variable] = action_config.subauth_map.external_name!(subauthority) if subauthority.present?

        Qa::IriTemlateService.build_url(url_config: action_config.url_config, substitutions: indifferent_substitutions)
      end
    end
  end
end
