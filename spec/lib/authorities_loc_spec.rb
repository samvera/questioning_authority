require 'spec_helper'

describe Qa::Authorities::Loc do

  before :all do
    stub_request(:get, "http://id.loc.gov/search/?format=json&q=haw*&q=cs:http://id.loc.gov/vocabulary/geographicAreas").
      with(:headers => {'Accept'=>'application/json'}).
      to_return(:body => webmock_fixture("loc-response.txt"), :status => 200)
    @authority = Qa::Authorities::Loc.new
    @authority.search("haw*", "geographicAreas")
  end

  describe "geographic areas" do
  
    it "should instantiate with a query and return data" do
      expect(@authority).not_to be_nil
      @authority.raw_response.to_s.should include("id")
    end  
  
    it "should return a sub_authority url" do
      @authority.should_not be_nil
      url = @authority.sub_authorityURL("geographicAreas")
      expect(url).not_to be_nil
    end
  
    it "should not return a url for an invalid sub_authority" do
      @authority.should_not be_nil
      url = @authority.sub_authorityURL("invalid sub_authority")
      expect(url).to eq("")
    end
  
    it "should return JSON" do
      @authority.should_not be_nil
      json = @authority.parse_authority_response(@authority.raw_response)
      expect(json).not_to be_empty
    end

  end

  describe "subject headings" do

    before :all do
      stub_request(:get, "http://id.loc.gov/search/?format=json&q=History--&q=cs:http://id.loc.gov/authorities/subjects").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:body => webmock_fixture("loc-subjects-response.txt"), :status => 200)
    end

    it "should be retrieved via search" do
      @authority.search("History--", "subjects")
      @authority.results.first["label"].should == "History--Philosophy--History--20th century"
    end

  end

  describe "name headings" do

    before :all do
      stub_request(:get, "http://id.loc.gov/search/?format=json&q=Berry&q=cs:http://id.loc.gov/authorities/names").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:body => webmock_fixture("loc-names-response.txt"), :status => 200)
    end

    it "should be retrieved via search" do
      @authority.search("Berry", "names")
      @authority.results.first["label"].should == "Berry, James W. (James William), 1938-"
    end
 
  end

  describe "#parse_authority_response" do
    before :all  do
      stub_request(:get, "http://id.loc.gov/search/?format=json&q=h&q=cs:http://id.loc.gov/authorities/subjects").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:body => webmock_fixture("loc-response.txt"), :status => 200)
      @authority.search("h", "subjects")
    end

    let(:parsed_response) { @authority.parse_authority_response(@authority.raw_response) }

    it "should return an array of entries returned in the JSON" do
      expect(parsed_response.length).to eq(2)
    end

    it "should have a URI for the id and a string label" do
      expect(parsed_response[0]["id"]).to eq("info:lc/authorities/names/n2008008718")
      expect(parsed_response[0]["label"]).to eq("Haw, Lily, 1890?-1915")
      expect(parsed_response[1]["id"]).to eq("info:lc/vocabulary/geographicAreas/n-us-hi")
      expect(parsed_response[1]["label"]).to eq("Hawaii")
    end
  end
end
