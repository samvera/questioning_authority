require 'spec_helper'

describe Qa::Authorities::Tgnlang do

  let(:subject) { @terms = Qa::Authorities::Tgnlang.new }

  describe "#search" do
    it "should return unique record with query of Tibetan" do
      subject.search("Tibetan").should == [{"id"=>"75446", "label"=>"Tibetan"}]
    end
    it "should return type Array" do
      subject.search("Tibetan").should be_kind_of(Array)
    end
  end

end
