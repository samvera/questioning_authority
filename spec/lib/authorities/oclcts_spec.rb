require 'spec_helper'

describe Qa::Authorities::Oclcts do
  before do
    stub_request(:get, "http://tspilot.oclc.org/mesh/?maximumRecords=10&operation=searchRetrieve&query=oclcts.rootHeading%20exact%20%22ball*%22&recordPacking=xml&recordSchema=http://zthes.z3950.org/xml/1.0/&recordXPath=&resultSetTTL=300&sortKeys=&startRecord=1&version=1.1")
      .to_return(body: webmock_fixture("oclcts-response-mesh-1.txt"), status: 200)
    stub_request(:get, "http://tspilot.oclc.org/mesh/?maximumRecords=10&operation=searchRetrieve&query=oclcts.rootHeading%20exact%20%22alph*%22&recordPacking=xml&recordSchema=http://zthes.z3950.org/xml/1.0/&recordXPath=&resultSetTTL=300&sortKeys=&startRecord=1&version=1.1")
      .to_return(body: webmock_fixture("oclcts-response-mesh-2.txt"), status: 200)
    stub_request(:get, "http://tspilot.oclc.org/mesh/?maximumRecords=10&operation=searchRetrieve&query=dc.identifier%20exact%20%22D031329Q000821%22&recordPacking=xml&recordSchema=http://zthes.z3950.org/xml/1.0/&recordXPath=&resultSetTTL=300&sortKeys=&startRecord=1&version=1.1")
      .to_return(body: webmock_fixture("oclcts-response-mesh-3.txt"), status: 200)

    @first_query = described_class.subauthority_for("mesh")
    @terms = @first_query.search("ball")
    @term_record = @first_query.find(@terms.first["id"])
    @second_query = described_class.subauthority_for("mesh")
    @second_query.search("alph")
  end

  describe "a query for terms" do
    it "has an array of hashes that match the query" do
      expect(@terms).to be_kind_of Array
      expect(@terms.first).to be_kind_of Hash
      expect(@terms.first["label"]).to be_kind_of String
      expect(@terms.first["label"]).to include "Ballota"
    end

    it "has an array of hashes containing unique id and label" do
      expect(@terms.first).to have_key("id")
      expect(@terms.first).to have_key("label")
    end
  end

  describe "a query for a single item" do
    it "has a hash of values that represent the item requested" do
      expect(@term_record).to be_kind_of Hash
      expect(@term_record.values).to include @terms.first["id"]
      expect(@term_record.values).to include @terms.first["label"]
    end

    it "succeeds for valid ids, even if the id is not in the initial list of responses" do
      record = @second_query.find(@terms.first["id"])
      expect(record.values).to include @terms.first["id"]
      expect(record.values).to include @terms.first["label"]
    end
  end
end
