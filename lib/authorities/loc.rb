require 'curl'

module Authorities
  class Loc < Authorities::Base

    # Initialze the Loc class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize(q, sub_authority='')
      authority_url = getAuthorityURL(sub_authority)

      http = Curl.get(
          "http://id.loc.gov/search/?q=#{q}&q=#{authority_url}&format=json"
      ) do |http|
        http.headers['Accept'] = 'application/json'
      end

      self.response = parse_authority_response(JSON.parse(http.body_str))
    end

    def getAuthorityURL(sub_authority)
      case sub_authority
        when ''    #This is equivalent to all vocabs
          return ''
        when 'iso639-2'
          return 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fiso639-2'
        else
          raise Exception, 'The LOC vocabulary sub authority value is not a valid'
      end
    end

    def parse_authority_response(raw_response)
      result = []
      raw_response.each do |single_response|
        if single_response[0] == "atom:entry"
          id = nil
          label = ''
          single_response.each do |result_part|
            if(result_part[0] == 'atom:title')
              label = result_part[2]
            end

            if(result_part[0] == 'atom:id')
              id = result_part[2]
            end

          end

          id ||= label
          result << {"id"=>id, "label"=>label}

        end
      end
      result
    end



    # TODO: there's other info in the self.response that might be worth making access to, such as
    # RDF links, etc.

  end
end