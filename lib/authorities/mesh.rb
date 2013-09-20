module Authorities
  class Mesh

    def initialize(q, sub_authority=nil)
      @q = q
    end

    def results
      @results ||= begin
                     r = SubjectMeshTerm.where('term_lower LIKE ?', "#{@q}%").limit(10)
                     r.map { |t| {id: t.term_id, label: t.term} }
                   end
    end

    def get_full_record(id)
      @results ||= begin
                     r = SubjectMeshTerm.where(term_id: id).limit(1).first
                     r.nil? ? nil : {id: r.term_id, label: r.term, synonyms: r.synonyms}
                   end
    end

    # satisfy TermsController
    def parse_authority_response
    end
  end
end
