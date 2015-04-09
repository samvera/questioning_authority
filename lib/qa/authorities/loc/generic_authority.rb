module Qa::Authorities
  class Loc::GenericAuthority < Base
    attr_reader :sub_authority
    def initialize(sub_authority)
      @sub_authority = sub_authority
    end

    include WebServiceBase

    def search q
      @raw_response = get_json(build_query_url(q))
      parse_authority_response
    end

    def build_query_url q
      escaped_query = URI.escape(q)
      authority_fragment = Loc.get_url_for_authority(sub_authority) + URI.escape(sub_authority)
      return "http://id.loc.gov/search/?q=#{escaped_query}&q=#{authority_fragment}&format=json"
    end

    def find id
      get_json(find_url(id))
    end

    def find_url id
      "http://id.loc.gov/authorities/#{@sub_authority}/#{id}.json"
    end

    private

    # Reformats the data received from the LOC service
    def parse_authority_response
      @raw_response.select {|response| response[0] == "atom:entry"}.map do |response|
        loc_response_to_qa(response_to_struct(response))
      end
    end

    # Converts most of the atom data into an OpenStruct object.
    #
    # Note that this is a pretty naive conversion.  There should probably just
    # be a class that properly translates and stores the various pieces of
    # data, especially if this logic could be useful in other auth lookups.
    def response_to_struct response
      result = response.each_with_object({}) do |result_parts, result|
        next unless result_parts[0]
        key = result_parts[0].sub('atom:', '').sub('dcterms:', '')
        info = result_parts[1]
        val = result_parts[2]

        case key
          when 'title', 'id', 'name', 'updated', 'created'
            result[key] = val
          when 'link'
            result["links"] ||= []
            result["links"] << [info["type"], info["href"]]
        end
      end

      OpenStruct.new(result)
    end

    # Simple conversion from LoC-based struct to QA hash
    def loc_response_to_qa data
      {
        "id" => data.id || data.title,
        "label" => data.title
      }
    end

  end
end
