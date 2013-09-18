class CreateSubjectMeshTerms < ActiveRecord::Migration
  def change
    create_table :subject_mesh_terms do |t|
      t.string :term_id
      t.string :term
      t.text :synonyms
    end
    add_index :subject_mesh_terms, :term_id
    add_index :subject_mesh_terms, :term
  end
end
