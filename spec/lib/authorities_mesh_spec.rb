require 'spec_helper'

describe Qa::Authorities::Mesh do
  def where_unique_record(klass, q)
    klass.where(q).length.should == 1
  end

  it "imports a mesh dump file" do
    m = Qa::Authorities::MeshTools::MeshImporter.new
    File.open(webmock_fixture('mesh.txt').path) do |f|
      m.import_from_file(f)
    end
    where_unique_record(Qa::SubjectMeshTerm, {term_lower: "malaria"})
    where_unique_record(Qa::SubjectMeshTerm, {term: "Malaria"})
    where_unique_record(Qa::SubjectMeshTerm, {term_id: "D008288"})
    Qa::SubjectMeshTerm.all.length.should == 11
  end

  describe "#results" do
    before(:all) do
      Qa::SubjectMeshTerm.create(term_id: '1', term: 'Mr Plow', term_lower: 'mr plow')
      Qa::SubjectMeshTerm.create(term_id: '2', term: 'Mr Snow', term_lower: 'mr snow')
      Qa::SubjectMeshTerm.create(term_id: '3', term: 'Mrs Fields', term_lower: 'mrs fields')
    end

    after(:all) do
      Qa::SubjectMeshTerm.delete_all
    end

    let(:m) { Qa::Authorities::Mesh.new }

    it "handles queries" do
      m.search('mr')
      results = m.results
      results.should include( {id: '1', label: 'Mr Plow'} )
      results.length.should == 3
    end

    it "gets full records" do
      result = m.full_record('2')
      result.should == {id: '2', label: 'Mr Snow', synonyms: []}
    end

    it "returns all records" do
      m.all.count.should == 3
      m.all.should include({:id=>"2", :label=>"Mr Snow"})
    end
  end
end
