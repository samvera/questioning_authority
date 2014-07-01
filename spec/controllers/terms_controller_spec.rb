require 'spec_helper'

describe Qa::TermsController do

  before do
    @routes = Qa::Engine.routes
  end

  describe "#check_vocab_param" do
    it "should return 404 if the vocabulary is missing" do
      get :search, { :q => "a query", :vocab => "" }
      expect(response.code).to eq("404")
    end
  end

  describe "#init_authority" do
    it "should return 404 if authority does not exist" do
      get :search, { :q => "a query", :vocab => "non-existent-authority" }
      expect(response.code).to eq("404")
    end
  end

  describe "#check_sub_authority" do
    it "should return 404 if sub_authority does not exist" do
      get :search, { :q => "a query", :vocab => "loc", :sub_authority => "non-existent-subauthority" }
      expect(response.code).to eq("404")
    end
  end

  describe "#search" do

    before :each do
      stub_request(:get, "http://id.loc.gov/search/?format=json&q=").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:body => webmock_fixture("loc-response.txt"), :status => 200)
      stub_request(:get, "http://id.loc.gov/search/?format=json&q=cs:http://id.loc.gov/vocabulary/relators").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:body => webmock_fixture("loc-response.txt"), :status => 200)
    end

    it "should return a set of terms for a tgnlang query" do
      get :search, {:q => "Tibetan", :vocab => "tgnlang" }
      expect(response).to be_success
    end

    it "should not return 404 if vocabulary is valid" do
      get :search, { :q => "foo", :vocab => "loc" }
      expect(response.code).to_not eq("404")
    end

    it "should not return 404 if sub_authority is valid" do
      get :search, { :q => "foo", :vocab => "loc", :sub_authority => "relators" }
      expect(response.code).to_not eq("404")
    end

  end

  describe "#index" do

    context "with supported authorities" do
      it "should return all local authority state terms" do
        get :index, { :vocab => "local", :sub_authority => "states" }
        response.should be_success
      end
      it "should return all MeSH terms" do
        get :index, { :vocab => "mesh" }
        response.should be_success
      end
    end

    context "when the authority does not support #all" do
      it "should return null for tgnlang" do
        get :index, { :vocab => "tgnlang"}
        response.body.should == "null"
      end
      it "should return null for oclcts" do
        get :index, { :vocab => "oclcts"}
        response.body.should == "null"
      end
      it "should return null for LOC authorities" do
        get :index, { :vocab => "loc", :sub_authority => "relators"}
        response.body.should == "null"
      end
    end

  end

  describe "#show" do
    it "the path resolves"
  end

end
