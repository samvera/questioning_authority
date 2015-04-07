module Qa::Authorities
  class Local < AuthorityWithSubAuthority

    include Qa::Authorities::LocalSubauthority

    def sub_authorities
      names
    end

    def search(q)
      r = q.blank? ? [] : terms.select { |term| /\b#{q.downcase}/.match(term[:term].downcase) }
      r.map do |res|
        { :id => res[:id], :label => res[:term] }.with_indifferent_access
      end
    end

    def all
      terms.map do |res|
        { :id => res[:id], :label => res[:term] }.with_indifferent_access
      end
    end

    def find(id)
      terms.find { |term| term[:id] == id } || {}
    end

    private 

    def terms
      sub_authority_hash = YAML.load(File.read(sub_authority_filename))
      terms = sub_authority_hash.with_indifferent_access.fetch(:terms, [])
      normalize_terms(terms)
    end

    def sub_authority_filename
      File.join(sub_authorities_path, "#{sub_authority}.yml")
    end

    def normalize_terms(terms)
      terms.map do |term|
        if term.is_a? String
          { :id => term, :term => term }.with_indifferent_access
        else
          term[:id] ||= term[:term]
          term
        end
      end
    end

  end
end
