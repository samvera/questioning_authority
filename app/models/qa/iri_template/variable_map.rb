# Provide access to iri template variable map configuration.
# See https://www.hydra-cg.com/spec/latest/core/#templated-links for information on IRI Templated Links - Variable Mapping.
# TODO: It would be good to find a more complete resource describing templated links.
module Qa
  module IriTemplate
    class VariableMap
      TYPE = "IriTemplateMapping".freeze
      attr_reader :variable
      attr_reader :default

      # @param [Hash] map configuration hash for the variable map
      # @option map [String] :variable name of the variable in the template (e.g. {?query} has the name 'query')
      # @option map [String] :property always "hydra:freetextQuery" # TODO what other values are supported and what do they mean
      # @option map [True | False] :required is this variable required
      # @option map [String] :default value to use if a value is not provided in the request
      def initialize(map)
        @variable = extract_variable(config: map)
        @required = extract_required(config: map)
        @default = extract_default(config: map)
        @property = map.fetch(:property, 'hydra:freetextQuery')
      end

      # Is this variable required?
      # @returns true if required; otherwise, false
      def required?
        @required
      end

      # TODO: When implementing more complex query substitution, simple_value is used when template url specifies variable as {var_name}.
      # Value to use in substitution, using default if one isn't passed in
      # @param [Object] value to use if it exists
      # @returns the value to use (e.g. 'fr')
      def simple_value(sub_value = nil)
        return sub_value.to_s if sub_value.present?
        raise Qa::IriTemplate::MissingParameter, "#{variable} is required, but missing" if required?
        default
      end

      # TODO: When implementing more complex query substitution, parameter_value is used when template url specifies variable as {?var_name}.
      # # Parameter and value to use in substitution, using default is one isn't passed in
      # # @param [Object] value to use if it exists
      # # @returns the parameter and value to use (e.g. 'language=fr')
      # def parameter_value(sub_value = nil)
      #   simple_value = simple_value(sub_value)
      #   return '' if simple_value.blank?
      #   param_value = "#{variable}=#{simple_value}"
      # end

      private

        # Extract the variable name from the config
        # @param config [Hash] configuration (json) holding the variable map
        # @return [String] variable for substitution in the url tmeplate
        def extract_variable(config:)
          varname = config.fetch(:variable, nil)
          raise Qa::InvalidConfiguration, 'variable is required' unless varname
          varname
        end

        # Extract the variable name from the config
        # @param config [Hash] configuration (json) holding the variable map
        # @return [True | False] required as true or false
        def extract_required(config:)
          required = config.fetch(:required, nil)
          raise Qa::InvalidConfiguration, 'required must be true or false' unless required == true || required == false
          required
        end

        # Extract the default value from the config
        # @param config [Hash] configuration (json) holding the variable map
        # @return [String] default value to use for the variable; defaults to empty string
        def extract_default(config:)
          config.fetch(:default, '').to_s
        end
    end
  end
end
