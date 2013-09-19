require 'spec_helper'

describe Authorities::Oclcts do

  before :each do
    WebMock.disable_net_connect!
    stub_request(:get, "http://tspilot.oclc.org/mesh/?maximumRecords=10&operation=searchRetrieve&query=oclcts.rootHeading%20exact%20%22ball*%22&recordPacking=xml&recordSchema=http://zthes.z3950.org/xml/1.0/&recordXPath=&resultSetTTL=300&sortKeys=&startRecord=1&version=1.1").
        to_return(:body => File.new(Rails.root.join("spec/fixtures", "oclcts-response-mesh-1.txt")), :status => 200)
    stub_request(:get, "http://tspilot.oclc.org/mesh/?maximumRecords=10&operation=searchRetrieve&query=oclcts.rootHeading%20exact%20%22alph*%22&recordPacking=xml&recordSchema=http://zthes.z3950.org/xml/1.0/&recordXPath=&resultSetTTL=300&sortKeys=&startRecord=1&version=1.1").
        to_return(:body => File.new(Rails.root.join("spec/fixtures", "oclcts-response-mesh-2.txt")), :status => 200)
    stub_request(:get, "http://tspilot.oclc.org/mesh/?maximumRecords=10&operation=searchRetrieve&query=dc.identifier%20exact%20%22D031329Q000821%22&recordPacking=xml&recordSchema=http://zthes.z3950.org/xml/1.0/&recordXPath=&resultSetTTL=300&sortKeys=&startRecord=1&version=1.1").
        to_return(:body => File.new(Rails.root.join("spec/fixtures", "oclcts-response-mesh-3.txt")), :status => 200)

    @first_query = Authorities::Oclcts.new("ball", "mesh")
    @terms = @first_query.parse_authority_response
    @term_record = @first_query.get_full_record @terms.first["id"]
    @second_query = Authorities::Oclcts.new("alph", "mesh")
  end

  after :each do
    WebMock.allow_net_connect!
  end

  describe "a query for terms" do

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

  describe "a query for a single item" do
    it "should have a hash of values that represent the item requested" do
      @term_record.should be_kind_of Hash
      @term_record.values.should include @terms.first["id"] 
      @term_record.values.should include @terms.first["label"]
    end
    
    it "should succeed for valid ids, even if the id is not in the initial list of responses" do
      record = @second_query.get_full_record @terms.first["id"]
      record.values.should include @terms.first["id"]
      record.values.should include @terms.first["label"]
    end
  end

 end  
