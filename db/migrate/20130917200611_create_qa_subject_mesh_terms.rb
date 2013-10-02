class CreateQaSubjectMeshTerms < ActiveRecord::Migration
  def change
    create_table :qa_subject_mesh_terms do |t|
      t.string :term_id
      t.string :term
      t.text :synonyms
    end
    add_index :qa_subject_mesh_terms, :term_id
    add_index :qa_subject_mesh_terms, :term
  end
end
