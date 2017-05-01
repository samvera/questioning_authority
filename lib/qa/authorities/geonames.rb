module Qa::Authorities
  class Geonames < Base
    include WebServiceBase

    class_attribute :username, :label

    self.label = lambda do |item|
      [item['name'], item['adminName1'], item['countryName']].compact.join(', ')
    end

    def search(q)
      unless username
        Rails.logger.error "Questioning Authority tried to call geonames, but no username was set"
        return []
      end
      parse_authority_response(json(build_query_url(q)))
    end

    def build_query_url(q)
      query = URI.escape(untaint(q))
      "http://api.geonames.org/searchJSON?q=#{query}&username=#{username}&maxRows=10"
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find(id)
      json(find_url(id))
    end

    def find_url(id)
      "http://www.geonames.org/getJSON?geonameId=#{id}&username=#{username}"
    end

    private

      # Reformats the data received from the service
      def parse_authority_response(response)
        response['geonames'].map do |result|
          # Note: the trailing slash is meaningful.
          { 'id' => "http://sws.geonames.org/#{result['geonameId']}/",
            'label' => label.call(result) }
        end
      end
  end
end
