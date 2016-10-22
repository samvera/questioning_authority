require 'spec_helper'

describe Qa::Authorities::LocSubauthority do
  let(:subject) do
    class TestAuthority
      include Qa::Authorities::LocSubauthority
    end
    TestAuthority.new
  end

  context "with a valid subauthority" do
    it "returns a url" do
      subauthority_table.keys.each do |authority|
        expect(subject.get_url_for_authority(authority)).to eq(subauthority_table[authority])
      end
    end
  end

  context "with a non-existent subauthority" do
    it "returns nil" do
      expect(subject.get_url_for_authority("fake")).to be_nil
    end
  end

  # This is the original data structure that was used to define subauthority urls
  # It is retained here to ensure our refactor succeeded
  def subauthority_table
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
