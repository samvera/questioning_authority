module Qa::Authorities
  class Mesh
    extend Deprecation

    def results
      @results ||= begin
                     r = Qa::SubjectMeshTerm.where('term_lower LIKE ?', "#{@q}%").limit(10)
                     r.map { |t| {id: t.term_id, label: t.term} }
                   end
    end

    def search(q, sub_authority=nil)
      @q = q
    end

    def full_record(id)
      @results ||= begin
                     r = Qa::SubjectMeshTerm.where(term_id: id).limit(1).first
                     r.nil? ? nil : {id: r.term_id, label: r.term, synonyms: r.synonyms}
                   end
    end

    def get_full_record(id)
      Deprecation.warn(Mesh, "get_full_record is deprecated and will be removed in 0.1.0. Use full_record instead", caller)
      full_record(id)
    end

    # satisfy TermsController
    def parse_authority_response
    end
    
  end
end
