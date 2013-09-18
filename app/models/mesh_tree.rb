class MeshTree < ActiveRecord::Base
  belongs_to :subject_mesh_term , :foreign_key => "term_id"

  def self.classify_all_trees
    MeshTreeStructure.find_each do |mts|
      mts.classify_tree!
    end
  end

  def eval_tree_path
    trees = read_attribute(:eval_tree_path) || write_attribute(:eval_tree_path, "")
    if trees
      trees.split("|")
    else
      []
    end
  end

  def classify_tree
    tree_levels = initial_segements_of(tree_structure)
    tree_levels.map &method(:lookup_tree_term)
  end

  def classify_tree!
    unless classify_tree.empty?
      tree_path = classify_tree.join('|')
      puts "After Join #{tree_path.inspect}"
      update_attribute(:eval_tree_path, tree_path)
    end
  end

  # given a tree id, return the main subject term
  # e.g. 'C03.752.530' returns 'Malaria'
  def lookup_tree_term(tree_id)
    self.class.get_term(tree_id).first.term
  end
end
