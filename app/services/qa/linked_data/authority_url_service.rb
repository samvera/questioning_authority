# Provide service for constructing the external access URL for an authority.
module Qa
  module LinkedData
    class AuthorityUrlService
      # Build a url for an authority/subauthority for the specified action.
      # @param authority [Symbol] name of a registered authority
      # @param subauthority [String] name of a subauthority
      # @param action [Symbol] action with valid values :search or :term
      # @param action_request [String] the request the user is making of the authority (e.g. query text or term id/uri)
      # @param substitutions [Hash] variable-value pairs to substitute into the URL template
      # @returns a valid URL the submits the action request to the external authority
      def self.build_url(authority:, subauthority: nil, action:, action_request:, substitutions: {})
        auth_config = Qa::LinkedData::AuthorityRegistryService.retrieve_or_create(authority)
        action_config = auth_config.action_config!(action)
        selected_substitutions = action_config.url_config.extract_substitutions(substitutions)
        selected_substitutions[action_config.action_request_variable] = action_request
        selected_substitutions[action_config.subauth_variable] = action_config.subauth_map.external_name!(subauthority) if subauthority.present?

        Qa::IriTemplateService.build_url(url_config: action_config.url_config, substitutions: selected_substitutions)
      end
    end
  end
end
