# Provide access to iri template variable map configuration.
# See https://www.hydra-cg.com/spec/latest/core/#templated-links for information on IRI Templated Links - Variable Mapping.
# TODO: It would be good to find a more complete resource describing templated links.

module Qa
  module IriTemplate
    class VariableMap
      TYPE = "IriTemplateMapping".freeze
      attr_reader :variable
      attr_reader :default
      private :default

      # @param [Hash] variable_map configuration hash for the variable map
      # @option variable_map [String] :variable (required) name of the variable in the template (e.g. {?query} has the name 'query')
      # @option variable_map [String] :property (optional) always "hydra:freetextQuery" # TODO what other values are supported and what do they mean
      # @option variable_map [Boolean] :required (required) is this variable required
      # @option variable_map [String] :default (optional) value to use if a value is not provided in the request (default: '')
      # @option variable_map [Boolean] :encode (optional) whether to url_encode the value (default: false)
      def initialize(variable_map)
        @variable = Qa::LinkedData::Config::Helper.fetch_required(variable_map, :variable, nil)
        @required = Qa::LinkedData::Config::Helper.fetch_boolean(variable_map, :required, nil)
        @default = Qa::LinkedData::Config::Helper.fetch(variable_map, :default, '').to_s
        @encode = Qa::LinkedData::Config::Helper.fetch_boolean(variable_map, :encode, false)
        @property = Qa::LinkedData::Config::Helper.fetch(variable_map, :property, 'hydra:freetextQuery')
      end

      # Value to use in substitution, using default if one isn't passed in.  Use when template url specifies variable as {var_name}.
      # @param [Object] value to use if it exists
      # @return the value to use (e.g. 'fr')
      def simple_value(sub_value = nil)
        raise Qa::IriTemplate::MissingParameter, "#{variable} is required, but missing" if sub_value.blank? && required?
        return default if sub_value.blank?
        sub_value = sub_value.to_s
        sub_value = ERB::Util.url_encode(sub_value).gsub(".", "%2E") if encode?
        sub_value
      end

      # Parameter and value to use in substitution, using default is one isn't passed in. Use when template url specifies variable as {?var_name}.
      # @param [Object] value to use if it exists
      # @return the parameter and value to use (e.g. 'language=fr')
      def parameter_value(sub_value = nil)
        simple_value = simple_value(sub_value)
        return '' if simple_value.blank?
        "#{variable}=#{simple_value}"
      end

      private

        # Is this variable required?
        # @return true if required; otherwise, false
        def required?
          @required
        end

        # Should the variable's value be encoded?
        # @return true if should encode; otherwise, false
        def encode?
          @encode
        end
    end
  end
end
