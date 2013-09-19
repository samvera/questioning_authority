require 'spec_helper'

describe TermsController do

  describe "#index" do

    describe "error checking" do

      it "should return 400 if no vocabulary is specified" do
        get :index, { :vocab => nil}
        response.code.should == "400"
      end
  
      it "should return 400 if no query is specified" do
        get :index, { :q => nil}
        response.code.should == "400"
      end

      it "should return 400 if vocabulary is not valid" do
        get :index, { :q => "foo", :vocab => "bar" }
        response.code.should == "400"
      end

      it "should not return 400 if vocabulary is valid" do
        get :index, { :q => "foo", :vocab => "loc" }
        response.code.should_not == "400"
      end

      it "should return 400 if sub_authority is not valid" do
        get :index, { :q => "foo", :vocab => "loc", :sub_authority => "foo" }
        response.code.should == "400"
      end

      it "should not return 400 if sub_authority is valid" do
        get :index, { :q => "foo", :vocab => "loc", :sub_authority => "relators" }
        response.code.should_not == "400"
      end
    end

    describe "successful queries" do

      before :all do
        WebMock.disable_net_connect!
        stub_request(:get, "http://id.loc.gov/authorities/suggest/?q=Blues").
        to_return(:body => File.new(Rails.root.join("spec/fixtures", "lcsh-response.txt")), :status => 200)
      end

      after :all do
        WebMock.allow_net_connect!
      end

      it "should return a set of terms for a lcsh query" do
        get :index, { :q => "Blues", :vocab => "lcsh" }
        response.should be_success
      end
      it "should return a set of terms for a tgnlang query" do
        get :index, {:q => "Tibetan", :vocab => "tgnlang" }
        response.should be_success
      end

    end
  
  end
end
