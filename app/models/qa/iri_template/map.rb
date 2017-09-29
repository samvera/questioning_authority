# Provide access to iri template variable map configuration.
module Qa
  module IriTemplate
    class Map
      TYPE = "IriTemplateMapping".freeze
      attr_reader :variable
      attr_reader :property
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
        @property = map.fetch(:property, "hydra:freetextQuery")
      end

      # Is this variable required?
      # @returns true if required; otherwise, false
      def required?
        @required
      end

      # Default value to use if one isn't provided
      # @returns true if required; otherwise, false
      def default
        return nil if required?
        @default
      end

      private

        # Extract the variable name from the config
        # @param config [Hash] configuration (json) holding the variable map
        # @param var [Symbol] key identifying the variable in the configuration
        # @return [String] variable for substitution in the url tmeplate
        def extract_variable(config:, var: :variable)
          varname = config.fetch(var, nil)
          raise ArgumentError, "variable is required" unless varname
          varname
        end

        # Extract the variable name from the config
        # @param config [Hash] configuration (json) holding the variable map
        # @param var [Symbol] key in the configuration identifying whether the variable is required
        # @return [True | False] required as true or false
        def extract_required(config:, var: :required)
          required = config.fetch(var, nil)
          raise ArgumentError, "required must be true or false" unless required == true || required == false
          required
        end

        # Extract the default value from the config ignoring defaults for required variables
        # @param config [Hash] configuration (json) holding the variable map
        # @param var [Symbol] key identifying the default value in the configuration
        # @return [String] default value to use for the variable; nil if variable is required
        def extract_default(config:, var: :default)
          return nil if required?
          config.fetch(var, "")
        end
    end
  end
end
