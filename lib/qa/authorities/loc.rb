require 'uri'

module Qa::Authorities
  class Loc < WebServiceBase

    # Initialze the Loc class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize
    end

    def search(q, sub_authority=nil)
      if ! (sub_authority.nil?  || Loc.sub_authorities.include?(sub_authority))
        @raw_response = nil
        @response = nil
        return
      end

      q = URI.escape(q)
      authority_fragment = sub_authorityURL(sub_authority)
      query_url =  "http://id.loc.gov/search/?q=#{q}&q=#{authority_fragment}&format=json"
      @raw_response = get_json(query_url)
      @response = parse_authority_response(@raw_response)
    end

    def self.sub_authority_table
      @sub_authority_table ||=
        begin
          vocab_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2F'
          authority_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2F'
          datatype_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fdatatypes%2F'
          vocab_preservation_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fpreservation%2F'
          {
            'subjects' => authority_base_url,
            'names' => authority_base_url,
            'classification' => authority_base_url,
            'childrensSubjects' => authority_base_url,
            'genreForms' => authority_base_url,
            'performanceMediums' => authority_base_url,
            'graphicMaterials' => vocab_base_url,
            'organizations' => vocab_base_url,
            'relators' => vocab_base_url,
            'countries' => vocab_base_url,
            'ethnographicTerms' => vocab_base_url,
            'geographicAreas' => vocab_base_url,
            'languages' => vocab_base_url,
            'iso639-1' => vocab_base_url,
            'iso639-2' => vocab_base_url,
            'iso639-5' => vocab_base_url,
            'edtf' => datatype_base_url,
            'preservation' => vocab_base_url,
            'actionsGranted' => vocab_base_url,
            'agentType' => vocab_base_url,
            'contentLocationType' => vocab_preservation_base_url,
            'copyrightStatus' => vocab_preservation_base_url,
            'cryptographicHashFunctions' => vocab_preservation_base_url,
            'environmentCharacteristic' => vocab_preservation_base_url,
            'environmentPurpose' => vocab_preservation_base_url,
            'eventRelatedAgentRole' => vocab_preservation_base_url,
            'eventRelatedObjectRole' => vocab_preservation_base_url,
            'eventType' => vocab_preservation_base_url,
            'formatRegistryRole' => vocab_preservation_base_url,
            'hardwareType' => vocab_preservation_base_url,
            'inhibitorTarget' => vocab_preservation_base_url,
            'inhibitorType' => vocab_preservation_base_url,
            'objectCategory' => vocab_preservation_base_url,
            'preservationLevelRole' => vocab_preservation_base_url,
            'relationshipSubType' => vocab_preservation_base_url,
            'relationshipType' => vocab_preservation_base_url,
            'rightsBasis' => vocab_preservation_base_url,
            'rightsRelatedAgentRole' => vocab_preservation_base_url,
            'signatureEncoding' => vocab_preservation_base_url,
            'signatureMethod' => vocab_preservation_base_url,
            'softwareType' => vocab_preservation_base_url,
            'storageMedium' => vocab_preservation_base_url
          }
        end
    end


    def sub_authorityURL(sub_authority)
      base_url = Loc.sub_authority_table[sub_authority]
      return "" if base_url.nil?
      base_url + URI.escape(sub_authority)
    end

    def self.authority_valid?(authority)
      self.sub_authorities.include?(authority)
    end

    def self.sub_authorities
      @sub_authorities ||= sub_authority_table.keys
    end

    def parse_authority_response(raw_responses)
      raw_responses.select {|response| response[0] == "atom:entry"}.map do |response|
        loc_response_to_qa(response_to_struct(response))
      end
    end

    # Converts most of the atom data into an OpenStruct object.
    #
    # Note that this is a pretty naive conversion.  There should probably just
    # be a class that properly translates and stores the various pieces of
    # data, especially if this logic could be useful in other auth lookups.
    def response_to_struct(response)
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
    def loc_response_to_qa(data)
      {
        "id" => data.id || data.title,
        "label" => data.title
      }
    end

    def find_record_in_response(raw_response, id)
      raw_response.each do |single_response|
        next if single_response[0] != "atom:entry"
        single_response.each do |result_part|
          if (result_part[0] == 'atom:title' ||
              result_part[0] == 'atom:id') && id == result_part[2]
            return single_response
          end
        end
      end
      return nil
    end

    def full_record(id, sub_authority)
      search(id, sub_authority)
      full_record = find_record_in_response(@raw_response, id)

      if full_record.nil?
        # record not found
        return {}
      end

      parsed_result = {}
      full_record.each do |section|
        if section.class == Array
          label = section[0].split(':').last.to_s
          case label
          when 'title', 'id', 'updated', 'created'
            parsed_result[label] = section[2]
          when 'link'
            if section[1]['type'] != nil
              parsed_result[label + "||#{section[1]['type']}"] = section[1]["href"]
            else
              parsed_result[label] = section[1]["href"]
            end
          when 'author'
            author_list = []
            #FIXME: Find example with two authors to better understand this data.
            author_list << section[2][2]
            parsed_result[label] = author_list
          end
        end
      end
      parsed_result
    end

  end
end
