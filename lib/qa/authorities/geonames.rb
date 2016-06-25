module Qa::Authorities
  class Geonames < Base
    include WebServiceBase

    class_attribute :username

    def search q
      parse_authority_response(json(build_query_url(q)))
    end

    # get_json is not ideomatic, so we'll make an alias
    def json(*args)
      get_json(*args)
    end

    def build_query_url q
      query = URI.escape(untaint(q))
      "http://api.geonames.org/searchJSON?q=#{query}&username=#{username}&maxRows=10"
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find id
      json(find_url(id))
    end

    def find_url id
      "http://www.geonames.org/getJSON?geonameId=#{id}&username=#{username}"
    end

    private

    # Reformats the data received from the service
    def parse_authority_response(response)
      response['geonames'].map do |result|
        { 'id' => "http://sws.geonames.org/#{result['geonameId']}",
          'label' => result['name'] }
      end
    end
  end
end
