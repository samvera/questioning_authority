require 'spec_helper'

describe Qa::TermsController do

  before do
    @routes = Qa::Engine.routes
  end

  describe "#index" do

    context "with errors" do

      it "should return 400 if no vocabulary is specified" do
        get :index, { :vocab => nil}
        expect(response.code).to  eq("400")
      end

      it "should return 400 if no query is specified" do
        get :index, { :q => nil}
        expect(response.code).to eq("400")
      end

      it "should return 400 if vocabulary is not valid" do
        get :index, { :q => "foo", :vocab => "bar" }
        expect(response.code).to eq("400")
      end

      it "should return 400 if sub_authority is not valid" do
        get :index, { :q => "foo", :vocab => "loc", :sub_authority => "foo" }
        expect(response.code).to eq("400")
      end

    end

    context "with successful queries" do

      before :each do
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=").
          with(:headers => {'Accept'=>'application/json'}).
          to_return(:body => webmock_fixture("loc-response.txt"), :status => 200)
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=cs:http://id.loc.gov/vocabulary/relators").
          with(:headers => {'Accept'=>'application/json'}).
          to_return(:body => webmock_fixture("loc-response.txt"), :status => 200)
      end

      it "should return a set of terms for a tgnlang query" do
        get :index, {:q => "Tibetan", :vocab => "tgnlang" }
        expect(response).to be_success
      end

      it "should not return 400 if vocabulary is valid" do
        get :index, { :q => "foo", :vocab => "loc" }
        expect(response.code).to_not eq("400")
      end

      it "should not return 400 if sub_authority is valid" do
        get :index, { :q => "foo", :vocab => "loc", :sub_authority => "relators" }
        expect(response.code).to_not eq("400")
      end

    end

    describe "#show" do
      it "the path resolves"
    end

  end
end
