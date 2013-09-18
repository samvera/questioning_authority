class AddTermLowerToSubjectMeshTerms < ActiveRecord::Migration
  def change
    add_column :subject_mesh_terms, :term_lower, :string
    add_index :subject_mesh_terms, :term_lower
    remove_index :subject_mesh_terms, :term
  end
end
