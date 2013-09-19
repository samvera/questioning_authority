require 'spec_helper'

describe Authorities::Loc do
  
  it "should instantiate with a query and return data" do
    authority = Authorities::Loc.new("america", "countries")
    expect(authority).not_to be_nil
    authority.raw_response.to_s.should include("xmlns")
  end  
  
  it "should return a sub_authority url" do
    authority = Authorities::Loc.new("america")
    authority.should_not be_nil
    url = authority.sub_authorityURL("countries")
    expect(url).not_to be_nil
  end
  
  it "should not return a url for an invalid sub_authority" do
    authority = Authorities::Loc.new("america")
    authority.should_not be_nil
    url = authority.sub_authorityURL("invalid sub_authority")
    expect(url).to eq("")
  end
  
  it "should return JSON" do
    authority = Authorities::Loc.new("software*", "subject")
    authority.should_not be_nil
    json = authority.parse_authority_response
    expect(json).not_to be_empty
  end
  
  
end