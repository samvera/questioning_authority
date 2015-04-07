require 'spec_helper'

describe Qa::TermsController, :type => :controller do

  before do
    @routes = Qa::Engine.routes
  end

  describe "#check_vocab_param" do
    it "should return 404 if the vocabulary is missing" do
      get :search, { :q => "a query", :vocab => "" }
      expect(response.code).to eq("404")
    end
  end

  describe "#check_query_param" do
    it "should return 404 if the query is missing" do
      get :search, { :q => "", :vocab => "tgnlang" }
      expect(response.code).to eq("404")
    end
  end

  describe "#init_authority" do
    context "when the authority does not exist" do
      it "should return 404" do
        expect(Rails.logger).to receive(:warn).with("Unable to initialize authority Qa::Authorities::Non-existent-authority")
        get :search, { :q => "a query", :vocab => "non-existent-authority" }
        expect(response.code).to eq("404")
      end
    end
    context "when a sub-authority does not exist" do
      it "should return 404 if a sub-authority does not exist" do
        expect(Rails.logger).to receive(:warn).with("Unable to initialize sub-authority non-existent-subauthority for Qa::Authorities::Loc")
        get :search, { :q => "a query", :vocab => "loc", :sub_authority => "non-existent-subauthority" }
        expect(response.code).to eq("404")
      end
    end
    context "when a sub-authority is absent" do
      it "should return 404 for LOC" do
        get :search, { :q => "a query", :vocab => "loc" }
        expect(response.code).to eq("404")
      end
      it "should return 404 for oclcts" do
        get :search, { :q => "a query", :vocab => "oclcts" }
        expect(response.code).to eq("404")
      end
    end
  end

  describe "#search" do

    before :each do
      stub_request(:get, "http://id.loc.gov/search/?format=json&q=Berry&q=cs:http://id.loc.gov/authorities/names").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(:body => webmock_fixture("loc-names-response.txt"), :status => 200)
    end

    it "should return a set of terms for a tgnlang query" do
      get :search, {:q => "Tibetan", :vocab => "tgnlang" }
      expect(response).to be_success
    end

    it "should not return 404 if sub_authority is valid" do
      get :search, { :q => "Berry", :vocab => "loc", :sub_authority => "names" }
      expect(response).to be_success
    end

  end

  describe "#index" do

    context "with supported authorities" do
      it "should return all local authority state terms" do
        get :index, { :vocab => "local", :sub_authority => "states" }
        expect(response).to be_success
      end
      it "should return all MeSH terms" do
        get :index, { :vocab => "mesh" }
        expect(response).to be_success
      end
    end

    context "when the authority does not support #all" do
      it "should return null for tgnlang" do
        get :index, { :vocab => "tgnlang" }
        expect(response.body).to eq("null")
      end
      it "should return null for oclcts" do
        get :index, { :vocab => "oclcts", :sub_authority => "mesh" }
        expect(response.body).to eq("null")
      end
      it "should return null for LOC authorities" do
        get :index, { :vocab => "loc", :sub_authority => "relators" }
        expect(response.body).to eq("null")
      end
    end

  end

  describe "#show" do

    context "with supported authorities" do

      before do
        stub_request(:get, "http://id.loc.gov/authorities/subjects/sh85077565.json").
          with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => webmock_fixture("loc-names-response.txt"), :headers => {})
      end

      it "should return an individual state term" do
        get :show, { :vocab => "local", :sub_authority => "states", id: "OH" }
        expect(response).to be_success
      end

      it "should return an individual MeSH term" do
        get :show, { vocab: "mesh", id: "D000001" }
        expect(response).to be_success
      end

      it "should return an individual subject term" do
        get :show, { vocab: "loc", sub_authority: "subjects", id: "sh85077565" }
        expect(response).to be_success
      end

    end

  end

end
