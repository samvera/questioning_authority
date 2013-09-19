require 'uri'

module Authorities
  class Loc < Authorities::Base

    # Initialze the Loc class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize(q, sub_authority='')
      authority_url = sub_authorityURL(sub_authority)
      self.query_url =  "http://id.loc.gov/search/?q=#{q}&q=#{authority_url}&format=json"

      super
    end

    def sub_authorityURL(sub_authority)
      vocab_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2F'
      authority_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2F'
      datatype_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fdatatypes%2F'
      vocab_preservation_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fpreservation%2F'

      case sub_authority
        when 'subjects'
          return authority_base_url + URI.escape(sub_authority)
        when 'names'
          return authority_base_url + URI.escape(sub_authority)
        when 'classification'
          return authority_base_url + URI.escape(sub_authority)
        when 'childrensSubjects'
          return authority_base_url + URI.escape(sub_authority)
        when 'genreForms'
          return authority_base_url + URI.escape(sub_authority)
        when 'graphicMaterials'
          return vocab_base_url + URI.escape(sub_authority)
        when 'organizations'
          return vocab_base_url + URI.escape(sub_authority)
        when 'relators'
          return vocab_base_url + URI.escape(sub_authority)
        when 'countries'
          return vocab_base_url + URI.escape(sub_authority)
        when 'geographicAreas'
          return vocab_base_url + URI.escape(sub_authority)
        when 'languages'
          return vocab_base_url + URI.escape(sub_authority)
        when 'iso639-1'
          return vocab_base_url + URI.escape(sub_authority)
        when 'iso639-2'
          return vocab_base_url + URI.escape(sub_authority)
        when 'iso639-5'
          return vocab_base_url + URI.escape(sub_authority)
        when 'edtf'
          return datatype_base_url + URI.escape(sub_authority)
        when 'preservation'
          return vocab_base_url + URI.escape(sub_authority)
        when 'actionsGranted'
          return vocab_base_url + URI.escape(sub_authority)
        when 'agentType'
          return vocab_base_url + URI.escape(sub_authority)
        when 'contentLocationType'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'copyrightStatus'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'cryptographicHashFunctions'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'environmentCharacteristic'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'environmentPurpose'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'eventRelatedAgentRole'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'eventRelatedObjectRole'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'eventType'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'formatRegistryRole'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'hardwareType'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'inhibitorTarget'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'inhibitorType'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'objectCategory'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'preservationLevelRole'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'relationshipSubType'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'relationshipType'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'rightsBasis'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'rightsRelatedAgentRole'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'signatureEncoding'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'signatureMethod'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'softwareType'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        when 'storageMedium'
          return vocab_preservation_base_url + URI.escape(sub_authority)
        else
          return ''
      end
    end

    def self.sub_authorities
      ['iso639-2', 'subjects', 'names', 'classification', 'childrensSubjects', 'genreForms', 'graphicMaterials', 'organizations', 'relators', 'countries', 'geographicAreas', 'languages', 'iso639-5', 'edtf', 'preservation', 'actionsGranted', 'agentType', 'contentLocationType', 'copyrightStatus', 'cryptographicHashFunctions', 'environmentCharacteristic', 'environmentPurpose', 'eventRelatedAgentRole', 'eventRelatedObjectRole', 'eventType', 'formatRegistryRole', 'hardwareType', 'inhibitorTarget', 'inhibitorType', 'objectCategory', 'preservationLevelRole', 'relationshipSubType', 'relationshipType', 'rightsBasis', 'rightsRelatedAgentRole', 'signatureEncoding', 'signatureMethod', 'softwareType', 'storageMedium']
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
      full_record = nil
      parsed_result = {}
      self.raw_response.each do |single_response|
        if single_response[0] == "atom:entry"

          single_response.each do |result_part|
            if(result_part[0] == 'atom:title')
              if id == result_part[2]
                full_record = single_response
              end
            end

            if(result_part[0] == 'atom:id')
              if id == result_part[2]
                full_record = single_response
              end
            end

          end

        end
      end


      if full_record != nil
        full_record.each do |section|
          if section.class == Array
            label = section[0].split(':').last.to_s
            case label
              when 'title'
                parsed_result[label] = section[2]
              when 'link'
                if section[1]['type'] != nil
                  parsed_result[label + "||#{section[1]['type']}"] = section[1]["href"]
                else
                  parsed_result[label] = section[1]["href"]
                end
              when 'id'
                parsed_result[label] = section[2]
              when 'author'
                author_list = []
                #FIXME: Find example with two authors to better understand this data.
                author_list << section[2][2]
                parsed_result[label] = author_list
              when 'updated'
                parsed_result[label] = section[2]
              when 'created'
                parsed_result[label] = section[2]
            end

          end
        end
      else
        raise Exception 'Lookup without using a result search first not implemented yet'
      end

      parsed_result

    end

  end
end