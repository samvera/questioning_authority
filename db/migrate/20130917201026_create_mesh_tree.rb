class CreateMeshTree < ActiveRecord::Migration
  def change
    create_table :mesh_trees do |t|
      t.string :term_id
      t.string :tree_number
    end
    add_index :mesh_trees, :term_id
    add_index :mesh_trees, :tree_number
  end
end
