module Qa::Authorities
  class Geonames < Base
    include WebServiceBase

    class_attribute :username, :label, :query_url_host, :find_url_host

    # You may need to change your query_url_host in your implementation. To do
    # so, in the installed application's config/initializers/qa.rb add the
    # following:
    #
    # @example
    #   Qa::Authorities::Geonames.query_url_host = "http://ws.geonames.net"
    #
    # @note This is not exposed as part of the configuration block, but is
    #       something you can add after the configuration block.
    # @todo Expose this magic value as a configuration option; Which likely
    #       requires consideration about how to do this for the general case
    self.query_url_host = "http://api.geonames.org"

    # You may need to change your query_url_host in your implementation. To do
    # so, in the installed application's config/initializers/qa.rb add the
    # following:
    #
    # @example
    #   Qa::Authorities::Geonames.find_url_host = "http://ws.geonames.net"
    #
    # @note This is not exposed as part of the configuration block, but is
    #       something you can add after the configuration block.
    # @todo Expose this magic value as a configuration option; Which likely
    #       requires consideration about how to do this for the general case
    self.find_url_host = "http://www.geonames.org"

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
      query = ERB::Util.url_encode(untaint(q))
      File.join(query_url_host, "searchJSON?q=#{query}&username=#{username}&maxRows=10")
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find(id)
      json(find_url(id))
    end

    def find_url(id)
      File.join(find_url_host, "getJSON?geonameId=#{id}&username=#{username}")
    end

    private

      # Reformats the data received from the service
      def parse_authority_response(response)
        response['geonames'].map do |result|
          # Note: the trailing slash is meaningful.
          { 'id' => "https://sws.geonames.org/#{result['geonameId']}/",
            'label' => label.call(result) }
        end
      end
  end
end
