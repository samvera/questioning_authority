module Qa::Authorities
  class Mesh < Base

    def search q
      begin
        r = Qa::SubjectMeshTerm.where('term_lower LIKE ?', "#{q}%").limit(10)
        r.map { |t| {id: t.term_id, label: t.term} }
      end
    end

    def find id
      begin
        r = Qa::SubjectMeshTerm.where(term_id: id).limit(1).first
        r.nil? ? nil : {id: r.term_id, label: r.term, synonyms: r.synonyms}
      end
    end

    def all
      begin
        r = Qa::SubjectMeshTerm.all
        r.map { |t| {id: t.term_id, label: t.term} }
      end
    end
    
  end
end
