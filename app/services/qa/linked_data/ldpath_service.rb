# Defines the external authority predicates used to extract additional context from the graph.
require 'ldpath'

module Qa
  module LinkedData
    class LdpathService
      VALUE_ON_ERROR = [].freeze

      # Create the ldpath program for a given ldpath.
      # @param [String] ldpath to follow to get a value from a graph (documation: http://marmotta.apache.org/ldpath/language.html)
      # @param [Hash] shortcut names for URI prefixes with key = part of predicate that is the same for all terms (e.g. { "madsrdf": "http://www.loc.gov/mads/rdf/v1#" })
      # @return [Ldpath::Program] an executable program that will extract a value from a graph
      def self.ldpath_program(ldpath:, prefixes: {})
        program_code = ""
        prefixes.each { |key, url| program_code << "@prefix #{key} : <#{url}> \;\n" }
        program_code << "property = #{ldpath} \;"
        Ldpath::Program.parse program_code
      rescue => e
        Rails.logger.warn("WARNING: #{I18n.t('qa.linked_data.ldpath.parse_logger_error')}... cause: #{e.message}\n   ldpath_program=\n#{program_code}")
        raise StandardError, I18n.t("qa.linked_data.ldpath.parse_error") + "... cause: #{e.message}"
      end

      # Evaluate an ldpath for a specific subject uri in the context of a graph and return the extracted values.
      # @param [Ldpath::Program] an executable program that will extract a value from a graph
      # @param [RDF::Graph] the graph
      # @param [RDF::URI] the subject uri
      ## @return [Array<String>] the extracted values based on the ldpath
      def self.ldpath_evaluate(program:, graph:, subject_uri:)
        return VALUE_ON_ERROR if program.blank?
        output = program.evaluate(subject_uri, context: graph, limit_to_context: Qa.config.limit_ldpath_to_context?)
        output.present? ? output['property'].uniq : nil
      rescue => e
        Rails.logger.warn("WARNING: #{I18n.t('qa.linked_data.ldpath.evaluate_logger_error')} (cause: #{e.message}")
        raise StandardError, I18n.t("qa.linked_data.ldpath.evaluate_error") + "... cause: #{e.message}"
      end
    end
  end
end
