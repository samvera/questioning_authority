# Defines the external authority predicates used to extract additional context from the graph.
require 'ldpath'

module Qa
  module LinkedData
    class LdpathService
      LANGUAGE_PATTERN = "*LANG*".freeze
      PROPERTY_NAME = "property".freeze

      class_attribute :predefined_prefixes
      self.predefined_prefixes = Ldpath::Transform.default_prefixes.with_indifferent_access

      class << self
        # Create the ldpath program for a given ldpath.
        # @param ldpath [String] ldpath to follow to get a value from a graph (documation: http://marmotta.apache.org/ldpath/language.html)
        # @param prefixes [Hash] shortcut names for URI prefixes with key = part of predicate that is the same for all terms (e.g. { "madsrdf": "http://www.loc.gov/mads/rdf/v1#" })
        # @param languages [Array<Symbol>] limit results to these languages and anything not tagged (applies to ldpaths with *LANG* marker)
        # @return [Ldpath::Program] an executable program that will extract a value from a graph
        def ldpath_program(ldpath:, prefixes: {}, languages: [])
          program_code = ldpath_program_code(ldpath: ldpath, prefixes: prefixes, languages: languages)
          Ldpath::Program.parse program_code
        rescue => e
          Rails.logger.warn("WARNING: #{I18n.t('qa.linked_data.ldpath.parse_logger_error')}... cause: #{e.message}\n   ldpath_program=\n#{program_code}")
          raise StandardError, I18n.t("qa.linked_data.ldpath.parse_error") + "... cause: #{e.message}"
        end

        # Create the program code for a given ldpath.
        # @param ldpath [String] ldpath to follow to get a value from a graph (documation: http://marmotta.apache.org/ldpath/language.html)
        # @param prefixes [Hash] shortcut names for URI prefixes with key = part of predicate that is the same for all terms (e.g. { "madsrdf": "http://www.loc.gov/mads/rdf/v1#" })
        # @param languages [Array<Symbol>] limit results to these languages and anything not tagged (applies to ldpaths with *LANG* marker)
        # @return [String] the program code string used with Ldpath::Program.parse
        def ldpath_program_code(ldpath:, prefixes: {}, languages: [])
          program_code = ""
          prefixes.each { |key, url| program_code << "@prefix #{key} : <#{url}> \;\n" }
          property_explode(program_code, ldpath, languages)
        end

        # Evaluate an ldpath for a specific subject uri in the context of a graph and return the extracted values.
        # @param program [Ldpath::Program] an executable program that will extract a value from a graph
        # @param graph [RDF::Graph] the graph from which the values will be extracted
        # @param subject_uri [RDF::URI] retrieved values will be limited to those with the subject uri
        # @param limit_to_context [Boolean] if true, the evaluation process will not make any outside network calls.
        #        It will limit results to those found in the context graph.
        ## @return [Array<RDF::Literal>] the extracted values based on the ldpath
        def ldpath_evaluate(program:, graph:, subject_uri:, limit_to_context: Qa.config.limit_ldpath_to_context?, maintain_literals: false)
          raise ArgumentError, "You must specify a program when calling ldpath_evaluate" if program.blank?
          output = program.evaluate(subject_uri, context: graph, limit_to_context: limit_to_context, maintain_literals: maintain_literals)
          maintain_literals ? property_implode(output) : output.values.flatten.uniq
        rescue ParseError => e
          Rails.logger.warn("WARNING: #{I18n.t('qa.linked_data.ldpath.evaluate_logger_error')} (cause: #{e.message}")
          raise ParseError, I18n.t("qa.linked_data.ldpath.evaluate_error") + "... cause: #{e.message}"
        end

        private

          # create program code with a property per language + untagged
          def property_explode(program_code, ldpath, languages)
            return program_code << "#{PROPERTY_NAME} = #{ldpath} \;\n" unless ldpath.index(LANGUAGE_PATTERN)
            return program_code << "#{PROPERTY_NAME} = #{ldpath.gsub(LANGUAGE_PATTERN, '')} \;\n" unless languages.present?
            languages.map { |language| program_code << "#{property_name_for(language)} = #{ldpath.gsub(LANGUAGE_PATTERN, "[@#{language}]")} \;\n" }
            program_code << "#{PROPERTY_NAME} = #{ldpath.gsub(LANGUAGE_PATTERN, '[@none]')} \;\n"
          end

          # flatten all properties and turn into RDF::Literals with language tagging if appropriate
          def property_implode(output)
            return nil if output.blank?
            output.each do |property_name, values|
              output[property_name] = remap_string_values(property_name, values) if values.first.is_a? String
            end
            output.values.flatten.uniq
          end

          def property_name_for(language)
            "#{language}_#{PROPERTY_NAME}"
          end

          def language_from(property_name)
            return nil if property_name.casecmp?(PROPERTY_NAME)
            property_name.chomp("_#{PROPERTY_NAME}")
          end

          def remap_string_values(property_name, values)
            language = language_from(property_name)
            values.map { |v| RDF::Literal.new(v, language: language) }
          end
      end
    end
  end
end
