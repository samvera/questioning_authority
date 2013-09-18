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

    it "should return nil if there's no query" do
      get :index, { :q => nil, :use_route => :lcsh_suggest }
      expect(assigns(:results)).to be_nil
    end

    it "should return a set of terms for a given query" do
      get :index, { :use_route => :lcsh_suggest, :q => "Blues" }
      expect(assigns(:results)).not_to be_nil
    end
  
  end
end