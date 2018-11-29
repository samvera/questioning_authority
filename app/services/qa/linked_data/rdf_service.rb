# Provide service for constructing the external access URL for an authority.
module Qa
  module LinkedData
    class RdfService
      # Retrieve linked data from specified url
      # @param [String] url from which to retrieve linked data
      # @param [String | Symbol | Array<String|Symbol>] language for filtering graph (e.g. "en" or :en or ["en", "fr"] or [:en, :fr])
      # @returns [RDF::Graph] graph of linked data
      def self.graph(url, language = nil)
        graph = RDF::Graph.load(url)
        graph = filter_language(graph, language) if graph.present? && language.present?
        graph
      rescue IOError => e
        process_error(e, url)
      end

      # Filter a graph to the specified language
      # @param [String | Symbol | Array<String|Symbol>] language for filtering graph (e.g. "en" or :en or ["en", "fr"] or [:en, :fr])
      # @returns [RDF::Graph] graph of linked data filtered on the specified language
      def self.filter_language(graph, language)
        language = normalize_language(language)
        return graph if language.blank?
        graph.each do |st|
          graph.delete(st) unless !st.object.respond_to?(:language) || st.object.language.nil? || language.include?(st.object.language)
        end
        graph
      end

      # Filter a graph to remove any statement with a blanknode for the subject
      # @param [RDF::Graph] the graph to be filtered.
      # @returns [RDF::Graph] graph of linked data with blanknodes removed
      def self.filter_out_subject_blanknodes(graph)
        return graph if graph.subjects.blank?
        graph.each do |st|
          graph.delete(st) if st.subject.anonymous?
        end
        graph
      end

      def self.process_error(e, url)
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
      private_class_method :process_error

      def self.ioerror_code(e)
        msg = e.message
        return 'format' if msg.start_with? "Unknown RDF format"
        a = msg.size - 4
        z = msg.size - 2
        msg[a..z]
      end
      private_class_method :ioerror_code

      # Normalize language
      # @param [String | Symbol | Array] language for filtering graph (e.g. "en" or :en or ["en", "fr"] or [:en, :fr])
      # @returns [Array<Symbol>] an array of languages encoded as symbols (e.g. [:en, :fr])
      def self.normalize_language(language)
        return if language.blank?
        language = [language] unless language.is_a? Array
        language.map(&:to_sym)
      end
      private_class_method :normalize_language
    end
  end
end
