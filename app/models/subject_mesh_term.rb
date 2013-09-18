class SubjectMeshTerm < ActiveRecord::Base
  has_many :mesh_trees, :foreign_key => "term_id"

  def self.from_tree_number(tree_id)
    SubjectMeshTerm.joins('INNER JOIN mesh_trees ON subject_mesh_terms.term_id = mesh_trees.term_id').where('mesh_trees.tree_number = ?', tree_id)
  end

  def trees
    MeshTree.where(term_id: self.term_id).map { |t| t.tree_number }
  end

  def synonyms
    s = read_attribute(:synonyms)
    s.nil? ? [] : s.split("|")
  end

  def synonyms=(syn_list)
    write_attribute(:synonyms,
                    if syn_list.respond_to?(:join)
                      syn_list.join('|')
                    else
                      syn_list
                    end)
  end

  def parents
    t = self.trees
    t.map { |tn| initial_segements_of(tn) }.flatten.uniq.map { |tn| SubjectMeshTerm.from_tree_number(tn) }
  end

  private
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

end
