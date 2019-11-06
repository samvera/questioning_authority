# Provide service for constructing the external access URL for an authority.
module Qa
  module LinkedData
    class AuthorityUrlService
      class << self
        # Build a url for an authority/subauthority for the specified action.
        # @param action_config [Qa::Authorities::LinkedData::SearchConfig | Qa::Authorities::LinkedData::TermConfig] action configuration for the authority
        # @param action [Symbol] action with valid values :search or :term
        # @param action_request [String] the request the user is making of the authority (e.g. query text or term id/uri)
        # @param request_header [Hash] optional attributes that can be appended to the generated URL
        # @option replacements [Hash] variable-value pairs to substitute into the URL template (optional)
        # @option subauthority [String] name of a subauthority (optional)
        # @option language [Array<Symbol>] languages for filtering returned literals (optional)
        # @return a valid URL that submits the action request to the external authority
        # @note All parameters after request_header are deprecated and will be removed in the next major release.
        def build_url(action_config:, action:, action_request:, request_header: {}, substitutions: {}, subauthority: nil, language: nil) # rubocop:disable Metrics/ParameterLists
          request_header = build_request_header(substitutions, subauthority, language) if request_header.empty?
          action_validation(action)
          url_config = action_config.url_config
          selected_substitutions = url_config.extract_substitutions(combined_substitutions(action_config, action, action_request, request_header))
          Qa::IriTemplateService.build_url(url_config: url_config, substitutions: selected_substitutions)
        end

        private

          def action_validation(action)
            return if [:search, :term].include? action
            raise Qa::UnsupportedAction, "#{action} Not Supported - Action must be one of the supported actions (e.g. :term, :search)"
          end

          def combined_substitutions(action_config, action, action_request, request_header)
            substitutions = request_header.fetch(:replacements, {})
            substitutions[action_request_variable(action_config, action)] = action_request
            substitutions[action_subauth_variable(action_config)] = action_subauth_variable_value(action_config, request_header)
            substitutions[action_language_variable(action_config)] = language_value(action_config, request_header)
            substitutions.reject { |_k, v| v.nil? }
            substitutions
          end

          def action_request_variable(action_config, action)
            key = action == :search ? :query : :term_id
            action_config.qa_replacement_patterns[key]
          end

          def action_subauth_variable(action_config)
            action_config.qa_replacement_patterns[:subauth]
          end

          def action_subauth_variable_value(action_config, request_header)
            subauth = request_header.fetch(:subauthority, nil)
            return nil unless subauth && action_config.supports_subauthorities?
            action_config.subauthorities[subauth.to_sym]
          end

          def action_language_variable(action_config)
            action_config.qa_replacement_patterns[:lang]
          end

          def language_value(action_config, request_header)
            return nil unless action_config.supports_language_parameter?
            request_header.fetch(:language, []).first
          end

          def build_request_header(substitutions, subauthority, language) # rubocop:disable Metrics/CyclomaticComplexity
            return {} if substitutions.blank? && subauthority.blank? && language.blank?
            Qa.deprecation_warning(
              in_msg: 'Qa::LinkedData::AuthorityUrlService',
              msg: "individual attributes for options (e.g. substitutions, subauthority, language) are deprecated; use request_header instead"
            )
            request_header = {}
            request_header[:replacements] = substitutions unless substititions.blank?
            request_header[:subauthority] = subauthority unless subauthority.blank?
            request_header[:language] = language unless language.blank?
            request_header
          end
      end
    end
  end
end
