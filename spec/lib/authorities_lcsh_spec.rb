require 'spec_helper'

describe Qa::Authorities::Lcsh do

  before :all do
    stub_request(:get, "http://id.loc.gov/authorities/suggest/?q=ABBA").
    to_return(:body => webmock_fixture("lcsh-response.txt"), :status => 200)
    @terms = Qa::Authorities::Lcsh.new
    @terms.search("ABBA")
  end


  describe "presenting the results from LOC" do

    it "has a list of responses" do
      @terms.response.should be_kind_of Array
      @terms.response.each do |item|
        item.should be_kind_of Hash
        item.keys.should == ["id", "label"]
      end
      @terms.response.map { |item| item["label"] }.should include "ABBA (Musical group)"
      @terms.response.map { |item| item["id"] }.should include "n78090836"
    end
  end

  describe "#build_response" do
    it "should set .response to be an array of hashes in the id/label structure" do
      sample = { "id"=>"n92117993", "label"=>"Abba (Nigeria)" }
      # use #send since build_response is private
      r = @terms.send(:build_response,
        ["ABBA",
         ["ABBA (Musical group)",
          "ABBA (Musical group). Gold",
          "ABBA (Organization)",
          "Abba (Nigeria)"],
         ["1 result",
          "1 result",
          "1 result",
          "1 result" ],
          ["http://id.loc.gov/authorities/names/n78090836",
           "http://id.loc.gov/authorities/names/n2003148504",
           "http://id.loc.gov/authorities/names/no2012083395",
           "http://id.loc.gov/authorities/names/n92117993"]]
      )
      r.should be_kind_of Array
      r.should include sample
    end
  end

end
