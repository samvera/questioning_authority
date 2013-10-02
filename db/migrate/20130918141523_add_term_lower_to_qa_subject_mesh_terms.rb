class AddTermLowerToQaSubjectMeshTerms < ActiveRecord::Migration
  def change
    add_column :qa_subject_mesh_terms, :term_lower, :string
    add_index :qa_subject_mesh_terms, :term_lower
    remove_index :qa_subject_mesh_terms, :term
  end
end
