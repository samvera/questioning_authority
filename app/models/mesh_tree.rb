class MeshTree < ActiveRecord::Base
  belongs_to :subject_mesh_term , :foreign_key => "term_id"

  attr_accessor :term_id, :tree_number

  def self.get_term(mesh_tree)
    SubjectMeshEntry.where(subject_mesh_term_id:
                                            MeshTreeStructure.where('mesh_tree_structures.tree_structure' => mesh_tree).map(&:subject_mesh_term_id)
                                          )
  end

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

  # Return all of the intial segements of our tree number,
  # from most general to most specific
  # e.g. 'D03.456.23.789' returns ['D03', 'D03.456', 'D03.456.23', 'D03.456.23.789']
  def initial_segements_of(s)
    result = []
    loop do
      result << s
      s = s.rpartition('.').first
      break if s.empty?
    end
    result.reverse
  end

  # given a tree id, return the main subject term
  # e.g. 'C03.752.530' returns 'Malaria'
  def lookup_tree_term(tree_id)
    self.class.get_term(tree_id).first.term
  end
end
