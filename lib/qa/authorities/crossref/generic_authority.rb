module Qa::Authorities
  class Crossref::GenericAuthority < Base
    include WebServiceBase
    class_attribute :label, :identifier
    attr_reader :subauthority

    def initialize(subauthority)
      @subauthority = subauthority
    end

    # Create a label from the crossref result hash
    #
    # @param item [Hash] the crossref result
    # @return [String] a label combining the name, alt-names and location
    self.label = lambda do |item|
      [item['name'],
       item['alt-names'].blank? ? nil : "(#{item['alt-names'].join(', ')})",
       item['location']].compact.join(', ')
    end

    def search(q)
      parse_authority_response(json(build_query_url(q)))
    end

    def build_query_url(q)
      query = URI.escape(untaint(q))
      "http://api.crossref.org/#{subauthority}?query=#{query}"
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find(id)
      json(find_url(id))
    end

    def find_url(id)
      "http://api.crossref.org/#{subauthority}/#{id}"
    end

    private

      # Reformats the data received from the service
      def parse_authority_response(response)
        response['message']['items'].map do |result|
          case subauthority
          when 'funders'
            { id: result['id'],
              uri: result['uri'],
              label: label.call(result),
              value: result['name'] }
          when 'journals'
            { id: result['ISSN'].first,
              label: result['title'],
              publisher: result['publisher'],
              issn: result['ISSN'] }

          end
        end
      end
  end
end
