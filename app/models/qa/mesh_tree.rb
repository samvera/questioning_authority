class Qa::MeshTree < ActiveRecord::Base
  belongs_to :subject_mesh_term, foreign_key: "term_id", primary_key: 'term_id'

  def self.classify_all_trees
    MeshTreeStructure.find_each(&:classify_tree!)
  end

  def eval_tree_path
    trees = self[:eval_tree_path] || (self[:eval_tree_path] = "")
    trees ? trees.split("|") : []
  end

  def classify_tree
    tree_levels = initial_segements_of(tree_structure)
    tree_levels.map(&:lookup_tree_term)
  end

  def classify_tree!
    unless classify_tree.empty? # rubocop:disable Style/GuardClause
      tree_path = classify_tree.join('|')
      Rails.logger.info "After Join #{tree_path.inspect}"
      update_attribute(:eval_tree_path, tree_path) # rubocop:disable Rails/SkipsModelValidations # TODO: Explore how to avoid use of update_attribute.
    end
  end

  # given a tree id, return the main subject term
  # e.g. 'C03.752.530' returns 'Malaria'
  def lookup_tree_term(tree_id)
    self.class.get_term(tree_id).first.term
  end
end
