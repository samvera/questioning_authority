module Qa::Authorities::LocSubauthority
  def get_url_for_authority(authority)
    if authorities.include?(authority) then authority_base_url
    elsif vocabularies.include?(authority) then vocab_base_url
    elsif datatypes.include?(authority)    then datatype_base_url
    elsif preservation.include?(authority) then vocab_preservation_base_url
    end
  end

  def authorities
    [
      "subjects",
      "names",
      "classification",
      "childrensSubjects",
      "genreForms",
      "performanceMediums"
    ]
  end

  def vocabularies
    [
      "graphicMaterials",
      "organizations",
      "relators",
      "countries",
      "ethnographicTerms",
      "geographicAreas",
      "languages",
      "iso639-1",
      "iso639-2",
      "iso639-5",
      "preservation",
      "actionsGranted",
      "agentType"
    ]
  end

  def datatypes
    ["edtf"]
  end

  def preservation
    [
      "contentLocationType",
      "copyrightStatus",
      "cryptographicHashFunctions",
      "environmentCharacteristic",
      "environmentPurpose",
      "eventRelatedAgentRole",
      "eventRelatedObjectRole",
      "eventType",
      "formatRegistryRole",
      "hardwareType",
      "inhibitorTarget",
      "inhibitorType",
      "objectCategory",
      "preservationLevelRole",
      "relationshipSubType",
      "relationshipType",
      "rightsBasis",
      "rightsRelatedAgentRole",
      "signatureEncoding",
      "signatureMethod",
      "softwareType",
      "storageMedium"
    ]
  end

  private

    def vocab_base_url
      "cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2F"
    end

    def authority_base_url
      "cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2F"
    end

    def datatype_base_url
      "cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fdatatypes%2F"
    end

    def vocab_preservation_base_url
      "cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fpreservation%2F"
    end
end
