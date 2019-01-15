# Provide access to iri template configuration.
# See https://www.hydra-cg.com/spec/latest/core/#templated-links for information on IRI Templated Links.
# TODO: It would be good to find a more complete resource describing templated links.
module Qa
  module IriTemplate
    class UrlConfig
      TYPE = "IriTemplate".freeze
      CONTEXT = "http://www.w3.org/ns/hydra/context.jsonld".freeze
      attr_reader :template # [String] the URL template with variables for substitution (required)
      attr_reader :variable_representation # [String] always "BasicRepresentation" # TODO what other values are supported and what do they mean
      attr_reader :mapping # [Array<Qa::IriTempalte::VariableMap>] array of maps for use with a template (required)

      # @param [Hash] url_config configuration hash for the iri template
      # @option url_config [String] :template the URL template with variables for substitution (required)
      # @option url_config [String] :variable_representation always "BasicRepresentation" # TODO what other values are supported and what do they mean
      # @option url_config [Array<Hash>] :mapping array of maps for use with a template (required)
      def initialize(url_config)
        @url_config = url_config
        @template = Qa::LinkedData::Config::Helper.fetch_required(url_config, :template, nil)
        @mapping = extract_mapping
        @variable_representation = Qa::LinkedData::Config::Helper.fetch(url_config, :variable_representation, 'BasicRepresentation')
      end

      # Selective extract substitution variable-value pairs from the provided substitutions.
      # @param [Hash, ActionController::Parameters] full set of passed in substitution values
      # @return [HashWithIndifferentAccess] Only variable-value pairs for variables defined in the variable mapping.
      def extract_substitutions(substitutions)
        selected_substitutions = HashWithIndifferentAccess.new
        mapping.each do |m|
          selected_substitutions[m.variable] = substitutions[m.variable] if substitutions.key? m.variable
        end
        selected_substitutions
      end

      private

        # Initialize the variable maps
        # @param config [Hash] configuration holding the variable maps to be extracted
        # @return [Array<IriTemplate::Map>] array of the variable maps
        def extract_mapping
          mapping = Qa::LinkedData::Config::Helper.fetch_required(@url_config, :mapping, nil)
          raise Qa::InvalidConfiguration, "mapping must include at least one map" if mapping.empty?
          mapping.collect { |m| Qa::IriTemplate::VariableMap.new(m) }
        end
    end
  end
end
