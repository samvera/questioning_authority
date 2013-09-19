require 'spec_helper'

describe Authorities::Tgnlang do

  before :all do
    @terms = Authorities::Tgnlang.new("Tibetan")
  end

  describe "response from dataset" do
    it "should return size 34 with query of Tibetan" do
      @terms.results.size.should == 34
    end
    it "should return type string" do
      @terms.results.class.name.should == "String"
    end
    it "should return a string it contains" do
      @terms.results["Tibetan"].should == "Tibetan"
    end

  end

end
