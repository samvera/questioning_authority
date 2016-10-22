require 'spec_helper'

describe Qa::Authorities::Mesh do
  def where_unique_record(klass, q)
    expect(klass.where(q).length).to eq(1)
  end

  it "imports a mesh dump file" do
    m = Qa::Authorities::MeshTools::MeshImporter.new
    File.open(webmock_fixture('mesh.txt').path) do |f|
      m.import_from_file(f)
    end
    where_unique_record(Qa::SubjectMeshTerm, term_lower: "malaria")
    where_unique_record(Qa::SubjectMeshTerm, term: "Malaria")
    where_unique_record(Qa::SubjectMeshTerm, term_id: "D008288")
    expect(Qa::SubjectMeshTerm.all.length).to eq(11)
  end

  describe "the query interface" do
    before(:all) do
      Qa::SubjectMeshTerm.create(term_id: '1', term: 'Mr Plow', term_lower: 'mr plow')
      Qa::SubjectMeshTerm.create(term_id: '2', term: 'Mr Snow', term_lower: 'mr snow')
      Qa::SubjectMeshTerm.create(term_id: '3', term: 'Mrs Fields', term_lower: 'mrs fields')
    end

    after(:all) do
      Qa::SubjectMeshTerm.delete_all
    end

    let(:m) { described_class.new }

    it "handles queries" do
      results = m.search('mr ')
      expect(results.length).to eq(2)
      expect(results).to include(id: '1', label: 'Mr Plow')
      expect(results).to include(id: '2', label: 'Mr Snow')
      expect(results).not_to include(id: '3', label: 'Mrs Fields')
    end

    it "returns individual records" do
      result = m.find('2')
      expect(result).to eq(id: '2', label: 'Mr Snow', synonyms: [])
    end

    it "returns all records" do
      expect(m.all.count).to eq(3)
      expect(m.all).to include(id: "2", label: "Mr Snow")
    end
  end
end
