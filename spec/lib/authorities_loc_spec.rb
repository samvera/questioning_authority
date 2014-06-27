require 'spec_helper'

describe Qa::Authorities::Loc do

  before :all do
    @authority = Qa::Authorities::Loc.new
  end

  describe "verify_configured_sub_authorities" do
    before :all do
      stub_request(:get, "http://id.loc.gov/search/?format=json&q=s&q=cs:http://id.loc.gov/vocabulary/geographicAreas").
          with(:headers => {'Accept'=>'application/json'}).
          to_return(:body => webmock_fixture("loc-response.txt"), :status => 200)

      @authority.search("s", "geographicAreas")
    end

    it "should detect invalid authorities" do
      @authority.should_not be_nil
      Qa::Authorities::Loc.authority_valid?("invalid sub_authority").should == false
    end

    it "should not return a url for an invalid sub_authority" do
      url = @authority.sub_authorityURL("invalid sub_authority")
      expect(url).to eq("")
    end

    it "should provide a url for a sub authority" do
      @authority.should_not be_nil
      url = @authority.sub_authorityURL("geographicAreas")
      expect(url).not_to be_nil
    end

    it "should detect valid sub authorities and provide correct urls" do
      vocab_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2F'
      authority_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2F'
      datatype_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fdatatypes%2F'
      vocab_preservation_base_url = 'cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fpreservation%2F'

      Qa::Authorities::Loc.authority_valid?("subjects").should == true
      @authority.sub_authorityURL("subjects").should == "#{authority_base_url}subjects"

      Qa::Authorities::Loc.authority_valid?("names").should == true
      @authority.sub_authorityURL("names").should == "#{authority_base_url}names"

      Qa::Authorities::Loc.authority_valid?("classification").should == true
      @authority.sub_authorityURL("classification").should == "#{authority_base_url}classification"

      Qa::Authorities::Loc.authority_valid?("childrensSubjects").should == true
      @authority.sub_authorityURL("childrensSubjects").should == "#{authority_base_url}childrensSubjects"

      Qa::Authorities::Loc.authority_valid?("genreForms").should == true
      @authority.sub_authorityURL("genreForms").should == "#{authority_base_url}genreForms"

      Qa::Authorities::Loc.authority_valid?("performanceMediums").should == true
      @authority.sub_authorityURL("performanceMediums").should == "#{authority_base_url}performanceMediums"

      Qa::Authorities::Loc.authority_valid?("edtf").should == true
      @authority.sub_authorityURL("edtf").should == "#{datatype_base_url}edtf"

      Qa::Authorities::Loc.authority_valid?("organizations").should == true
      @authority.sub_authorityURL("organizations").should == "#{vocab_base_url}organizations"

      Qa::Authorities::Loc.authority_valid?("relators").should == true
      @authority.sub_authorityURL("relators").should == "#{vocab_base_url}relators"

      Qa::Authorities::Loc.authority_valid?("countries").should == true
      @authority.sub_authorityURL("countries").should == "#{vocab_base_url}countries"

      Qa::Authorities::Loc.authority_valid?("ethnographicTerms").should == true
      @authority.sub_authorityURL("ethnographicTerms").should == "#{vocab_base_url}ethnographicTerms"

      Qa::Authorities::Loc.authority_valid?("languages").should == true
      @authority.sub_authorityURL("languages").should == "#{vocab_base_url}languages"

      Qa::Authorities::Loc.authority_valid?("iso639-1").should == true
      @authority.sub_authorityURL("iso639-1").should == "#{vocab_base_url}iso639-1"

      Qa::Authorities::Loc.authority_valid?("iso639-2").should == true
      @authority.sub_authorityURL("iso639-2").should == "#{vocab_base_url}iso639-2"

      Qa::Authorities::Loc.authority_valid?("iso639-5").should == true
      @authority.sub_authorityURL("iso639-5").should == "#{vocab_base_url}iso639-5"

      Qa::Authorities::Loc.authority_valid?("actionsGranted").should == true
      @authority.sub_authorityURL("actionsGranted").should == "#{vocab_base_url}actionsGranted"

      Qa::Authorities::Loc.authority_valid?("agentType").should == true
      @authority.sub_authorityURL("agentType").should == "#{vocab_base_url}agentType"

      Qa::Authorities::Loc.authority_valid?("contentLocationType").should == true
      @authority.sub_authorityURL("contentLocationType").should == "#{vocab_preservation_base_url}contentLocationType"

      Qa::Authorities::Loc.authority_valid?("copyrightStatus").should == true
      @authority.sub_authorityURL("copyrightStatus").should == "#{vocab_preservation_base_url}copyrightStatus"

      Qa::Authorities::Loc.authority_valid?("cryptographicHashFunctions").should == true
      @authority.sub_authorityURL("cryptographicHashFunctions").should == "#{vocab_preservation_base_url}cryptographicHashFunctions"

      Qa::Authorities::Loc.authority_valid?("environmentCharacteristic").should == true
      @authority.sub_authorityURL("environmentCharacteristic").should == "#{vocab_preservation_base_url}environmentCharacteristic"

      Qa::Authorities::Loc.authority_valid?("environmentPurpose").should == true
      @authority.sub_authorityURL("environmentPurpose").should == "#{vocab_preservation_base_url}environmentPurpose"

      Qa::Authorities::Loc.authority_valid?("eventRelatedAgentRole").should == true
      @authority.sub_authorityURL("eventRelatedAgentRole").should == "#{vocab_preservation_base_url}eventRelatedAgentRole"

      Qa::Authorities::Loc.authority_valid?("eventRelatedObjectRole").should == true
      @authority.sub_authorityURL("eventRelatedObjectRole").should == "#{vocab_preservation_base_url}eventRelatedObjectRole"

      Qa::Authorities::Loc.authority_valid?("eventType").should == true
      @authority.sub_authorityURL("eventType").should == "#{vocab_preservation_base_url}eventType"

      Qa::Authorities::Loc.authority_valid?("formatRegistryRole").should == true
      @authority.sub_authorityURL("formatRegistryRole").should == "#{vocab_preservation_base_url}formatRegistryRole"

      Qa::Authorities::Loc.authority_valid?("hardwareType").should == true
      @authority.sub_authorityURL("hardwareType").should == "#{vocab_preservation_base_url}hardwareType"

      Qa::Authorities::Loc.authority_valid?("inhibitorTarget").should == true
      @authority.sub_authorityURL("inhibitorTarget").should == "#{vocab_preservation_base_url}inhibitorTarget"

      Qa::Authorities::Loc.authority_valid?("inhibitorType").should == true
      @authority.sub_authorityURL("inhibitorType").should == "#{vocab_preservation_base_url}inhibitorType"

      Qa::Authorities::Loc.authority_valid?("objectCategory").should == true
      @authority.sub_authorityURL("objectCategory").should == "#{vocab_preservation_base_url}objectCategory"

      Qa::Authorities::Loc.authority_valid?("preservationLevelRole").should == true
      @authority.sub_authorityURL("preservationLevelRole").should == "#{vocab_preservation_base_url}preservationLevelRole"

      Qa::Authorities::Loc.authority_valid?("relationshipSubType").should == true
      @authority.sub_authorityURL("relationshipSubType").should == "#{vocab_preservation_base_url}relationshipSubType"

      Qa::Authorities::Loc.authority_valid?("relationshipType").should == true
      @authority.sub_authorityURL("relationshipType").should == "#{vocab_preservation_base_url}relationshipType"

      Qa::Authorities::Loc.authority_valid?("rightsBasis").should == true
      @authority.sub_authorityURL("rightsBasis").should == "#{vocab_preservation_base_url}rightsBasis"

      Qa::Authorities::Loc.authority_valid?("rightsRelatedAgentRole").should == true
      @authority.sub_authorityURL("rightsRelatedAgentRole").should == "#{vocab_preservation_base_url}rightsRelatedAgentRole"

      Qa::Authorities::Loc.authority_valid?("signatureEncoding").should == true
      @authority.sub_authorityURL("signatureEncoding").should == "#{vocab_preservation_base_url}signatureEncoding"

      Qa::Authorities::Loc.authority_valid?("signatureMethod").should == true
      @authority.sub_authorityURL("signatureMethod").should == "#{vocab_preservation_base_url}signatureMethod"

      Qa::Authorities::Loc.authority_valid?("softwareType").should == true
      @authority.sub_authorityURL("softwareType").should == "#{vocab_preservation_base_url}softwareType"

      Qa::Authorities::Loc.authority_valid?("storageMedium").should == true
      @authority.sub_authorityURL("storageMedium").should == "#{vocab_preservation_base_url}storageMedium"
    end
  end


  describe "canned_example_searches" do

    describe "geographic_search" do
      before :all do
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=s&q=cs:http://id.loc.gov/vocabulary/geographicAreas").
            with(:headers => {'Accept'=>'application/json'}).
            to_return(:body => webmock_fixture("loc-response.txt"), :status => 200)

        @authority.search("s", "geographicAreas")
      end

      it "should instantiate with a query and return data" do
        expect(@authority).not_to be_nil
        @authority.raw_response.to_s.should include("id")
      end

      it "should return JSON" do
        @authority.should_not be_nil
        json = @authority.parse_authority_response(@authority.raw_response)
        expect(json).not_to be_empty
      end

      it "should have certain returned elements" do
        @authority.results.first["label"].should == "West (U.S.)"
        @authority.results.first["id"].should == "info:lc/vocabulary/geographicAreas/n-usp"
        @authority.results.last["label"].should == "Baltic States"
        @authority.results.last["id"].should == "info:lc/vocabulary/geographicAreas/eb"
        @authority.results.size.should == 20
      end

    end

    describe "subject_search" do
      before :all do
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=History--&q=cs:http://id.loc.gov/authorities/subjects").
            with(:headers => {'Accept'=>'application/json'}).
            to_return(:body => webmock_fixture("loc-subjects-response.txt"), :status => 200)

        @authority.search("History--", "subjects")
      end

      it "should return an array of entries returned in the JSON" do
        @parsed_response = @authority.parse_authority_response(@authority.raw_response)
        expect(@parsed_response.length).to eq(20)
      end

      it "should have a URI for the id and a string label" do
        @authority.results.first["label"].should == "History--Philosophy--History--20th century"
        @authority.results.first["id"].should == "info:lc/authorities/subjects/sh2008121753"
        @authority.results[1]["label"].should == "History--Philosophy--History--19th century"
        @authority.results[1]["id"].should == "info:lc/authorities/subjects/sh2008121752"
      end

    end

    describe "name_search" do
      before :all do
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=Berry&q=cs:http://id.loc.gov/authorities/names").
            with(:headers => {'Accept'=>'application/json'}).
            to_return(:body => webmock_fixture("loc-names-response.txt"), :status => 200)
      end

      it "should retrieve names via search" do
        @authority.search("Berry", "names")
        @authority.results.first["label"].should == "Berry, James W. (James William), 1938-"
      end

    end
  end
end
