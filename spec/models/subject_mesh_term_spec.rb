require 'spec_helper'

describe SubjectMeshTerm do
  before(:all) do
    @term = SubjectMeshTerm.new
    @term.term_id = "ABCDEFG"
    @term.term = "Glyphon"
    @term.save!
  end
  it "returns an empty synonym list" do
    @term.synonyms.should == []
  end
  it "returns a list of trees" do
    @term.trees.should == []
  end
  it "saves a synonym list" do
    a = SubjectMeshTerm.new
    a.term_id = 'a'
    a.synonyms = ['b','c']
    a.save
    a.synonyms.should == ['b', 'c']
  end
  it "finds a term by tree number" do
    t = MeshTree.new
    t.term_id = @term.term_id
    t.tree_number = "D1.2.3.4"
    t.save!
    a = SubjectMeshTerm.from_tree_number("D1.2.3.4")
    a.length.should == 1
  end
end
