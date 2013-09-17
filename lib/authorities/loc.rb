require 'curl'

module Authorities
  class Loc < Authorities::Base

    # Initialze the Loc class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize(q, sub_authority='')
      self.query_url =  "http://id.loc.gov/search/?q=#{q}&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2F#{sub_authority}&format=json"

      super
    end

    def sub_authorities
      ['iso639-2', 'subjects', 'names', 'classification', 'childrensSubjects', 'genreForms']
    end


    def parse_authority_response
      result = []
      self.raw_response.each do |single_response|
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
      self.response = result
    end

    def get_full_record(id)
      # implement me
      specific_id = id.split('/').last
      initialize(specific_id)

    end

    # TODO: there's other info in the self.response that might be worth making access to, such as
    # RDF links, etc.

  end
end