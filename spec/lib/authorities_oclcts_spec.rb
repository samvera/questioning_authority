require 'spec_helper'

describe Authorities::Oclcts do

  before :all do
    WebMock.disable_net_connect!
    # TODO: Need a more elegant way to stub the request when the URL string is crazy long
    stub_request(:get, "http://tspilot.oclc.org/mesh/?maximumRecords=10&operation=searchRetrieve&query=oclcts.rootHeading%20exact%20%22ball*%22&recordPacking=xml&recordSchema=http://zthes.z3950.org/xml/1.0/&recordXPath=&resultSetTTL=300&sortKeys=&startRecord=1&version=1.1").
    # TODO: Where should response text files go?
    to_return(:body => File.new(Rails.root.join("spec/fixtures", "oclcts-response.txt")), :status => 200)

    @terms = Authorities::Oclcts.new("ball", "mesh").parse_authority_response
    WebMock.allow_net_connect!

  end

  # TODO: These test the reponse from SRU server and should be moved to
  # integration later once we can mock the response here
  describe "the response from SRU" do

    it "should have an array of hashes that match the query" do
      @terms.should be_kind_of Array
      @terms.first.should be_kind_of Hash
      @terms.first["label"].should be_kind_of String
      @terms.first["label"].should include "Ballota"
    end

    it "should have an array of hashes containing unique id and label" do
      @terms.first.should have_key("id")
      @terms.first.should have_key("label")
    end

  end



 end  
