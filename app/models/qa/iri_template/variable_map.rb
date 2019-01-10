# Provide access to iri template variable map configuration.
# See https://www.hydra-cg.com/spec/latest/core/#templated-links for information on IRI Templated Links - Variable Mapping.
# TODO: It would be good to find a more complete resource describing templated links.
require 'erb'

module Qa
  module IriTemplate
    class VariableMap
      include ERB::Util

      TYPE = "IriTemplateMapping".freeze
      attr_reader :variable
      attr_reader :default
      private :default

      # @param [Hash] map configuration hash for the variable map
      # @option map [String] :variable (required) name of the variable in the template (e.g. {?query} has the name 'query')
      # @option map [String] :property (optional) always "hydra:freetextQuery" # TODO what other values are supported and what do they mean
      # @option map [Boolean] :required (required) is this variable required
      # @option map [String] :default (optional) value to use if a value is not provided in the request (default: '')
      # @option map [Boolean] :encode (optional) whether to url_encode the value (default: false)
      def initialize(map)
        @variable = extract_variable(config: map)
        @required = extract_required(config: map)
        @default = extract_default(config: map)
        @encode = extract_encode(config: map)
        @property = map.fetch(:property, 'hydra:freetextQuery')
      end

      # TODO: When implementing more complex query substitution, simple_value is used when template url specifies variable as {var_name}.
      # Value to use in substitution, using default if one isn't passed in
      # @param [Object] value to use if it exists
      # @returns the value to use (e.g. 'fr')
      def simple_value(sub_value = nil)
        raise Qa::IriTemplate::MissingParameter, "#{variable} is required, but missing" if sub_value.blank? && required?
        return default if sub_value.blank?
        sub_value = sub_value.to_s
        sub_value = url_encode(sub_value).gsub(".", "%2E") if encode?
        sub_value
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

        # Is this variable required?
        # @returns true if required; otherwise, false
        def required?
          @required
        end

        # Should the variable's value be encoded?
        # @returns true if should encode; otherwise, false
        def encode?
          @encode
        end

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

        # Extract whether the value should be encoded
        # @param config [Hash] configuration (json) holding the variable map
        # @return [True | False] encode as true or false
        def extract_encode(config:)
          encode = config.fetch(:encode, false)
          raise Qa::InvalidConfiguration, 'encode must be true or false' unless encode == true || encode == false
          encode
        end
    end
  end
end
