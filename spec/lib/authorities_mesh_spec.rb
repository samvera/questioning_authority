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
end
