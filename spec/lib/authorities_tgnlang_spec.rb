require 'spec_helper'

describe Qa::Authorities::Tgnlang do

  let(:subject) { @terms = Qa::Authorities::Tgnlang.new }

  describe "#search" do
    it "should return unique record with query of Tibetan" do
      expect(subject.search("Tibetan")).to eq([{"id"=>"75446", "label"=>"Tibetan"}])
    end
    it "should return type Array" do
      expect(subject.search("Tibetan")).to be_kind_of(Array)
    end
  end

end
