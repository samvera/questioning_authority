require 'spec_helper'

describe Authorities::Mesh do
  def where_unique_record(klass, q)
    klass.where(q).length.should == 1
  end

  it "imports a mesh dump file" do
    m = Authorities::MeshTools::MeshImporter.new
    File.open(Rails.root + 'spec/fixtures/mesh.txt') do |f|
      m.import_from_file(f)
    end
    where_unique_record(SubjectMeshTerm, {term_lower: "malaria"})
    where_unique_record(SubjectMeshTerm, {term: "Malaria"})
    where_unique_record(SubjectMeshTerm, {term_id: "D008288"})
    SubjectMeshTerm.all.length.should == 11
  end

  describe "#results" do
    before(:all) do
      SubjectMeshTerm.create(term_id: '1', term: 'Mr Plow', term_lower: 'mr plow')
      SubjectMeshTerm.create(term_id: '2', term: 'Mr Snow', term_lower: 'mr snow')
      SubjectMeshTerm.create(term_id: '3', term: 'Mrs Fields', term_lower: 'mrs fields')
    end

    after(:all) do
      SubjectMeshTerm.delete_all
    end

    it "handles queries" do
      m = Authorities::Mesh.new('mr')
      results = m.results
      results.should include( {id: '1', label: 'Mr Plow'} )
      results.length.should == 3
    end
  end
end
