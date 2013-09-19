require 'spec_helper'

describe Authorities::Loc do
  
  before :all do
    WebMock.disable_net_connect!
    # TODO: Need a more elegant way to stub the request when the URL string is crazy long
    # This uses the WebMock gem.
    # Any requests to this URL will use the mock return data in the loc-response.txt file  
    stub_request(:get, "http://id.loc.gov/search/?format=json&q=haw*&q=cs:http://id.loc.gov/vocabulary/geographicAreas").
      with(:headers => {'Accept'=>'application/json'}).
      to_return(:body => File.new(Rails.root.join("spec/fixtures", "loc-response.txt")), :status => 200)
    @authority = Authorities::Loc.new("haw*", "geographicAreas")
  end

  after :all do
    WebMock.allow_net_connect!
  end
  
  
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
    #authority = Authorities::Loc.new("software*")
    @authority.should_not be_nil
    url = @authority.sub_authorityURL("invalid sub_authority")
    expect(url).to eq("")
  end
  
  it "should return JSON" do
    @authority.should_not be_nil
    json = @authority.parse_authority_response
    expect(json).not_to be_empty
  end
  
  
end