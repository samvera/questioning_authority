require 'rdf'
require	'linkeddata'
module Qa::Authorities
  module LinkedData
    module RdfHelper
      private

        def get_linked_data(url)
          begin
            graph = RDF::Graph.load(url)
          rescue IOError => e
            process_error(e, url)
          end
          graph
        end

        def process_error(e, url)
          uri = URI(url)
          response_code = ioerror_code(e)
          case response_code
          when '404'
            raise Qa::TermNotFound, "#{uri} Not Found - Term may not exist at LOD Authority. (HTTPNotFound - 404)"
          when '500'
            raise Qa::ServiceUnavailable, "#{uri.hostname} on port #{uri.port} is not responding.  Try again later. (HTTPServerError - 500)"
          when '503'
            raise Qa::ServiceUnavailable, "#{uri.hostname} on port #{uri.port} is not responding.  Try again later. (HTTPServiceUnavailable - 503)"
          else
            raise Qa::ServiceUnavailable, "#{uri.hostname} on port #{uri.port} is not responding.  Try again later. (Cause - #{response_code})"
          end
        end

        def ioerror_code(e)
          msg = e.message
          a = msg.size - 4
          z = msg.size - 2
          msg[a..z]
        end

        def filter_language(graph, language)
          language = normalize_language(language)
          return graph if language.nil?
          graph.each do |st|
            graph.delete(st) unless !st.object.respond_to?(:language) || st.object.language.nil? || language.include?(st.object.language)
          end
          graph
        end

        def normalize_language(language)
          language = [language.to_sym] if language.is_a? String
          language = [language] if language.is_a? Symbol
          return nil unless language.is_a? Array
          language
        end

        def extract_preds(graph, preds)
          RDF::Query.execute(graph) do
            preds[:required].each do |key, pred|
              pattern([:uri, pred, key])
            end
            preds[:optional].each do |key, pred|
              pattern([:uri, pred, key], optional: true)
            end
          end
        end

        def sort_string_by_language(str_literals)
          return str_literals if str_literals.nil? || str_literals.size <= 0
          str_literals.sort! { |a, b| a.language <=> b.language }
          str_literals.collect!(&:to_s)
          str_literals.uniq!
          str_literals.delete_if { |s| s.nil? || s.length <= 0 }
        end

        def blank_node?(obj)
          return true if obj.to_s.starts_with? "_:g"
          false
        end
    end
  end
end
