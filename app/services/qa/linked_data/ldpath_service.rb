# Defines the external authority predicates used to extract additional context from the graph.
require 'ldpath'

module Qa
  module LinkedData
    class LdpathService
      VALUE_ON_ERROR = [].freeze

      # Create the ldpath program for a given ldpath.
      # @param ldpath [String] ldpath to follow to get a value from a graph (documation: http://marmotta.apache.org/ldpath/language.html)
      # @param prefixes [Hash] shortcut names for URI prefixes with key = part of predicate that is the same for all terms (e.g. { "madsrdf": "http://www.loc.gov/mads/rdf/v1#" })
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
      # @param program [Ldpath::Program] an executable program that will extract a value from a graph
      # @param graph [RDF::Graph] the graph from which the values will be extracted
      # @param subject_uri [RDF::URI] retrieved values will be limited to those with the subject uri
      # @param limit_to_context [Boolean] if true, the evaluation process will not make any outside network calls.
      #        It will limit results to those found in the context graph.
      ## @return [Array<String>] the extracted values based on the ldpath
      def self.ldpath_evaluate(program:, graph:, subject_uri:, limit_to_context: Qa.config.limit_ldpath_to_context?)
        return VALUE_ON_ERROR if program.blank?
        output = program.evaluate(subject_uri, context: graph, limit_to_context: limit_to_context)
        output.present? ? output['property'].uniq : nil
      rescue => e
        Rails.logger.warn("WARNING: #{I18n.t('qa.linked_data.ldpath.evaluate_logger_error')} (cause: #{e.message}")
        raise StandardError, I18n.t("qa.linked_data.ldpath.evaluate_error") + "... cause: #{e.message}"
      end
    end
  end
end
