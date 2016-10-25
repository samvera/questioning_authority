module Qa::Authorities
  class Mesh < Base
    def search(q)
      r = Qa::SubjectMeshTerm.where('term_lower LIKE ?', "#{q}%").limit(10)
      r.map { |t| { id: t.term_id, label: t.term } }
    end

    def find(id)
      r = Qa::SubjectMeshTerm.where(term_id: id).limit(1).first
      r.nil? ? nil : { id: r.term_id, label: r.term, synonyms: r.synonyms }
    end

    def all
      r = Qa::SubjectMeshTerm.all
      r.map { |t| { id: t.term_id, label: t.term } }
    end
  end
end
