# Provide access to iri template configuration.
module Qa
  module IriTemplate
    class Template
      TYPE = "IriTemplate".freeze
      CONTEXT = "http://www.w3.org/ns/hydra/context.jsonld".freeze
      attr_reader :template # [String] the URL template with variables for substitution (required)
      attr_reader :variable_representation # [String] always "BasicRepresentation" # TODO what other values are supported and what do they mean
      attr_reader :mapping # [Array<Qa::IriTempalte::Map>] array of maps for use with a template (required)

      # @param [Hash] url_template configuration hash for the iri template
      # @option url_template [String] :template the URL template with variables for substitution (required)
      # @option url_template [String] :variable_representation always "BasicRepresentation" # TODO what other values are supported and what do they mean
      # @option url_template [Array<Hash>] :mapping array of maps for use with a template (required)
      def initialize(url_template)
        @template = extract_template(config: url_template)
        @mapping = extract_mapping(config: url_template)
        @variable_representation = url_template.fetch(:variable_representation, 'BasicRepresentation')
      end

      private

        # Initialize the variable maps
        # @param config [Hash] configuration (json) holding the variable maps to be extracted
        # @param var [Symbol] key identifying the variable mapping array in the configuration
        # @return [Array<IriTemplate::Map>] array of the variable maps
        def extract_mapping(config:, var: :mapping)
          mapping = config.fetch(var, nil)
          raise ArgumentError, "mapping is required" unless mapping
          raise ArgumentError, "mapping must include at least one map" if mapping.empty?
          mapping.collect { |m| Qa::IriTemplate::Map.new(m) }
        end

        # Extract the url template from the config
        # @param config [Hash] configuration (json) holding the template to be extracted
        # @param var [Symbol] key identifying the template in the configuration
        # @return [String] url template for accessing the authority
        def extract_template(config:, var: :template)
          template = config.fetch(var, nil)
          raise ArgumentError, "template is required" unless template
          template
        end
    end
  end
end
