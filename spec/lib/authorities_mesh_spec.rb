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

    it "handles queries" do
      pending "Re-enable this test once Mesh#results is changed to return a hash of results instead of a single json string"
      m = Authorities::Mesh.new('mr')
      results = m.results
      results.should include( {id: '1', label: 'Mr Plow'} )
      results.length.should == 3
    end
  end
end
