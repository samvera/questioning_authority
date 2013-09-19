require 'spec_helper'

describe Qa::Authorities::Tgnlang do

  before :all do
    @terms = Qa::Authorities::Tgnlang.new
    @terms.search("Tibetan")
  end

  describe "response from dataset" do
    it "should return unique record with query of Tibetan" do
      @terms.results.should == [{"id"=>"75446", "label"=>"Tibetan"}]
    end
    it "should return type Array" do
      @terms.results.class.should == Array
    end
  end

end
