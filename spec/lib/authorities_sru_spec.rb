require 'spec_helper'

describe Authorities::SRU do

  before :all do
    @terms = Authorities::SRU.new("ball", "mesh").response
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
