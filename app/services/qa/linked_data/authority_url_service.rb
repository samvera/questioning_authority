# Provide service for constructing the external access URL for an authority.
module Qa
  module LinkedData
    class AuthorityUrlService
      class << self
        # Build a url for an authority/subauthority for the specified action.
        # @param authority [Symbol] name of a registered authority
        # @param subauthority [String] name of a subauthority
        # @param action [Symbol] action with valid values :search or :term
        # @param action_request [String] the request the user is making of the authority (e.g. query text or term id/uri)
        # @param substitutions [Hash] variable-value pairs to substitute into the URL template
        # @return a valid URL the submits the action request to the external authority
        def build_url(action_config:, action:, action_request:, substitutions: {}, subauthority: nil)
          action_validation(action)
          url_config = action_config.url_config
          selected_substitutions = url_config.extract_substitutions(combined_substitutions(action_config, action, action_request, substitutions, subauthority))
          Qa::IriTemplateService.build_url(url_config: url_config, substitutions: selected_substitutions)
        end

        private

          def action_validation(action)
            return if [:search, :term].include? action
            raise Qa::UnsupportedAction, "#{action} Not Supported - Action must be one of the supported actions (e.g. :term, :search)"
          end

          def combined_substitutions(action_config, action, action_request, substitutions, subauthority)
            substitutions[action_request_variable(action_config, action)] = action_request
            substitutions[action_subauth_variable(action_config)] = action_subauth_variable_value(action_config, subauthority) if subauthority.present?
            substitutions
          end

          def action_request_variable(action_config, action)
            key = action == :search ? :query : :term_id
            action_config.qa_replacement_patterns[key]
          end

          def action_subauth_variable(action_config)
            action_config.qa_replacement_patterns[:subauth]
          end

          def action_subauth_variable_value(action_config, subauthority)
            action_config.subauthorities[subauthority.to_sym]
          end
      end
    end
  end
end
