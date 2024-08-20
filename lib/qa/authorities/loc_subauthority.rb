module Qa::Authorities::LocSubauthority
  # @todo Rename to reflect that this is a URI encoded url fragement used only for searching.
  def get_url_for_authority(authority)
    if authorities.include?(authority) then authority_base_url
    elsif vocabularies.include?(authority) then vocab_base_url
    elsif datatypes.include?(authority)    then datatype_base_url
    elsif preservation.include?(authority) then vocab_preservation_base_url
    end
  end

  # @note The returned value is the root directory of the URL.  The graphicMaterials sub-authority
  #       has a "type" of vocabulary.  https://id.loc.gov/vocabulary/graphicMaterials/tgm008083.html
  #       In some cases, this is plural and in others this is singular.
  #
  # @param authority [String] the LOC authority that matches one of the types
  # @return [String]
  #
  # @note there is a relationship between the returned value and the encoded URLs returned by
  #       {#get_url_for_authority}.
  def root_fetch_slug_for(authority)
    validate_subauthority!(authority)
    return "authorities" if authorities.include?(authority)
    return "vocabulary" if vocabularies.include?(authority)
    return "datatype" if datatypes.include?(authority)
    return "vocabulary/preservation" if preservation.include?(authority)
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

  def vocabularies # rubocop:disable Metrics/MethodLength
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

  def preservation # rubocop:disable Metrics/MethodLength
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
