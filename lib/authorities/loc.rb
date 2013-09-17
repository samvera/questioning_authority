require 'curl'

module Authorities
  class Loc

    attr_accessor :response

    # Initialze the Loc class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize(q, sub_authority='')
      authority_url = getAuthorityURL(sub_authority)

      http = Curl.get(
          "http://id.loc.gov/search/?q=#{q}&q=#{authority_url}&format=json"
      ) do |http|
        http.headers['Accept'] = 'application/json'
      end
      puts  parseAuthorityResponse(JSON.parse(http.body_str))
      self.response = parseAuthorityResponse(JSON.parse(http.body_str))
    end

    def getAuthorityURL(authority)
      case authority # a_variable is the variable we want to compare
        when ''    #compare to 1
          return ''
        when 'iso639-2'    #compare to 2
          return 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fiso639-2'
        else
          raise Exception, 'The LOC vocabulary sub authority value is not a valid'
      end
    end

    def parseAuthorityResponse(raw_response)
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

    # Parse the result from LOC, and return an JSON array of terms that match the query.
    def results
      self.response[1].to_json
    end

    # TODO: there's other info in the self.response that might be worth making access to, such as
    # RDF links, etc.

  end
end