# Extend the RDF graph to include additional processing methods.
module Qa
  module LinkedData
    class GraphService
      class << self
        # Retrieve linked data from specified url
        # @param [String] url from which to retrieve linked data
        # @return [RDF::Graph] graph of linked data
        def load_graph(url:)
          RDF::Graph.load(url)
        rescue IOError => e
          process_error(e, url)
        end

        # Create a new graph with statements filtered out
        # @param graph [RDF::Graph] the original graph to be filtered
        # @param language [String | Symbol | Array<String|Symbol>] will keep any statement whose object's language matches the language filter
        #          (only applies to statements that respond to language) (e.g. "en" or :en or ["en", "fr"] or [:en, :fr])
        # @param remove_blanknode_subjects [Boolean] will remove any statement whose subject is a blanknode, if true
        # @return [RDF::Graph] a new instance of graph with statements not matching the filters removed
        def filter(graph:, language: nil, remove_blanknode_subjects: false)
          return graph unless graph.present?
          return graph unless language.present? || remove_blanknode_subjects
          filtered_graph = graph
          language = normalize_language(language)
          filtered_graph.each do |st|
            filtered_graph.delete(st) if filter_out_blanknode(remove_blanknode_subjects, st.subject) || filter_out_language(language, st.object)
          end
          filtered_graph
        end

        # Get object values from the graph that have the subject-predicate.
        # @param graph [RDF::Graph] the graph to search
        # @param subject [RDF::URI] the URI of the subject
        # @param predicate [RDF::URI] the URI of the predicate
        # @return [Array] all object values for the subject-predicate pair
        def object_values(graph:, subject:, predicate:)
          values = []
          graph.query([subject, predicate, :object]) do |statement|
            values << statement.object
          end
          values
        end

        private

          def filter_out_blanknode(remove, subj)
            remove && subj.anonymous?
          end

          def filter_out_language(language, obj)
            return false if language.blank?
            return false unless obj.respond_to?(:language)
            return false if obj.language.blank?
            !language.include?(obj.language)
          end

          def process_error(e, url)
            uri = URI(url)
            raise RDF::FormatError, "Unknown RDF format of results returned by #{uri}. (RDF::FormatError)  You may need to include gem 'linkeddata'." if e.is_a? RDF::FormatError
            response_code = ioerror_code(e)
            case response_code
            when '404'
              raise Qa::TermNotFound, "#{uri} Not Found - Term may not exist at LOD Authority. (HTTPNotFound - 404)"
            when '500'
              raise Qa::ServiceError, "#{uri.hostname} on port #{uri.port} is not responding.  Try again later. (HTTPServerError - 500)"
            when '503'
              raise Qa::ServiceUnavailable, "#{uri.hostname} on port #{uri.port} is not responding.  Try again later. (HTTPServiceUnavailable - 503)"
            else
              raise Qa::ServiceError, "Unknown error for #{uri.hostname} on port #{uri.port}.  Try again later. (Cause - #{e.message})"
            end
          end

          def ioerror_code(e)
            msg = e.message
            return 'format' if msg.start_with? "Unknown RDF format"
            a = msg.size - 4
            z = msg.size - 2
            msg[a..z]
          end

          # Normalize language
          # @param [String | Symbol | Array] language for filtering graph (e.g. "en" OR :en OR ["en", "fr"] OR [:en, :fr])
          # @return [Array<Symbol>] an array of languages encoded as symbols (e.g. [:en] OR [:en, :fr])
          def normalize_language(language)
            return language if language.blank?
            language = [language] unless language.is_a? Array
            language.map(&:to_sym)
          end
      end
    end
  end
end
