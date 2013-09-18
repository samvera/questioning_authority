require 'spec_helper'

describe SubjectMeshTerm do
  before(:all) do
    @term = SubjectMeshTerm.new
    @term.term_id = "ABCDEFG"
    @term.term = "Glyphon"
    @term.save
  end
  it "returns an empty synonym list" do
    @term.synonyms.should == []
  end
  it "returns a list of trees" do
    @term.trees.should == []
  end
end
