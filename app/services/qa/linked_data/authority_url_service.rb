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
      # @return a valid URL the submits the action request to the external authority
      def self.build_url(action_config:, action:, action_request:, substitutions: {}, subauthority: nil)
        action_validation(action)
        url_config = Qa::IriTemplate::UrlConfig.new(action_url(action_config, action))
        selected_substitutions = url_config.extract_substitutions(substitutions)
        selected_substitutions[action_request_variable(action_config, action)] = action_request
        selected_substitutions[action_subauth_variable(action_config, action)] = action_subauth_variable_value(action_config, subauthority, action) if subauthority.present?

        Qa::IriTemplateService.build_url(url_config: url_config, substitutions: selected_substitutions)
      end

      def self.action_validation(action)
        return if [:search, :term].include? action
        raise Qa::UnsupportedAction, "#{action} Not Supported - Action must be one of the supported actions (e.g. :term, :search)"
      end
      private_class_method :action_validation

      # TODO: elr - rename search and term config methods to be the same to avoid all the ternary checks
      def self.action_url(auth_config, action)
        action == :search ? auth_config.url : auth_config.term_url
      end
      private_class_method :action_url

      def self.action_request_variable(action_config, action)
        key = action == :search ? :query : :term_id
        action == :search ? action_config.qa_replacement_patterns[key] : action_config.term_qa_replacement_patterns[key]
      end
      private_class_method :action_request_variable

      def self.action_subauth_variable(action_config, action)
        action == :search ? action_config.qa_replacement_patterns[:subauth] : action_config.term_qa_replacement_patterns[:subauth]
      end
      private_class_method :action_subauth_variable

      def self.action_subauth_variable_value(action_config, subauthority, action)
        case action
        when :search
          pattern = action_subauth_variable(action_config, action)
          default = action_config.url_mappings[pattern.to_sym][:default]
          action_config.subauthorities[subauthority.to_sym] || default
        when :term
          pattern = action_subauth_variable(action_config, action)
          default = action_config.term_url_mappings[pattern.to_sym][:default]
          action_config.term_subauthorities[subauthority.to_sym] || default
        end
      end
      private_class_method :action_subauth_variable_value
    end
  end
end
