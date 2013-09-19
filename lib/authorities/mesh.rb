module Authorities
  class Mesh

    def initialize(q, sub_authority=nil)
      @q = q
    end

    def results
      @results ||= begin
                     r = SubjectMeshTerm.where('term_lower LIKE ?', "#{@q}%").limit(10)
                     r.map { |t| {id: t.term_id, label: t.term} }
                   end.to_json
    end

    # satisfy TermsController
    def parse_authority_response
    end
  end
end
