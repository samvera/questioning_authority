require 'spec_helper'

describe SubjectMeshTerm do
  before(:all) do
    @term = SubjectMeshTerm.new
    @term.term_id = "ABCDEFG"
    @term.term = "Glyphon"
    @term.save!
  end
  after(:all) do
    @term.destroy
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

  it "returns parents"
  #do
  #  SubjectMeshTerm.create(term_id: "1")
  #  SubjectMeshTerm.create(term_id: "2")
  #  SubjectMeshTerm.create(term_id: "3")
  #  MeshTree.create(term_id: @term.term_id, tree_number: "D1.2.3")
  #  MeshTree.create(term_id: @term.term_id, tree_number: "D1.A.3")
  #  MeshTree.create(term_id: '2', tree_number: "D1.2")
  #  MeshTree.create(term_id: '3', tree_number: "D1.A")
  #  MeshTree.create(term_id: '1', tree_number: "D1")

  #  @term.trees.should == ["D1.2.3", "D1.A.3"]
  #  @term.parents.map { |p| p.term_id }.should == ["1", "2", "3"]
  #end
end
