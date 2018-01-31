# Provide access to iri template configuration.
module Qa
  module IriTemplate
    class UrlConfig
      TYPE = "IriTemplate".freeze
      CONTEXT = "http://www.w3.org/ns/hydra/context.jsonld".freeze
      attr_reader :template # [String] the URL template with variables for substitution (required)
      attr_reader :variable_representation # [String] always "BasicRepresentation" # TODO what other values are supported and what do they mean
      attr_reader :mapping # [Array<Qa::IriTempalte::VariableMap>] array of maps for use with a template (required)

      # @param [Hash] url_template configuration hash for the iri template
      # @option url_template [String] :template the URL template with variables for substitution (required)
      # @option url_template [String] :variable_representation always "BasicRepresentation" # TODO what other values are supported and what do they mean
      # @option url_template [Array<Hash>] :mapping array of maps for use with a template (required)
      def initialize(url_config)
        @template = extract_template(config: url_config)
        @mapping = extract_mapping(config: url_config)
        @variable_representation = url_config.fetch(:variable_representation, 'BasicRepresentation')
      end

      # Selective extract substitution variable-value pairs from the provided substitutions.
      # @param [Hash, ActionController::Parameters] full set of passed in substitution values
      # @returns [HashWithIndifferentAccess] Only variable-value pairs for variables defined in the variable mapping.
      def extract_substitutions(substitutions)
        selected_substitutions = HashWithIndifferentAccess.new()
        mapping.each do |m|
          selected_substitutions[m.variable] = substitutions[m.variable] if substitutions.key? m.variable
        end
        selected_substitutions
      end

      private

        # Extract the url template from the config
        # @param config [Hash] configuration (json) holding the template to be extracted
        # @param var [Symbol] key identifying the template in the configuration
        # @return [String] url template for accessing the authority
        def extract_template(config:, var: :template)
          template = config.fetch(var, nil)
          raise Qa::InvalidConfiguration, "template is required" unless template
          template
        end

        # Initialize the variable maps
        # @param config [Hash] configuration (json) holding the variable maps to be extracted
        # @param var [Symbol] key identifying the variable mapping array in the configuration
        # @return [Array<IriTemplate::Map>] array of the variable maps
        def extract_mapping(config:, var: :mapping)
          mapping = config.fetch(var, nil)
          raise Qa::InvalidConfiguration, "mapping is required" unless mapping
          raise Qa::InvalidConfiguration, "mapping must include at least one map" if mapping.empty?
          mapping.collect { |m| Qa::IriTemplate::VariableMap.new(m) }
        end
    end
  end
end
