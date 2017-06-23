module Qa::Authorities
  class Local::FileBasedAuthority < Base
    attr_reader :subauthority
    def initialize(subauthority)
      @subauthority = subauthority
    end

    def search(q)
      r = q.blank? ? [] : terms.select { |term| /\b#{q.downcase}/.match(term[:term].downcase) }
      r.map do |res|
        { id: res[:id], label: res[:term] }.with_indifferent_access
      end
    end

    def all
      terms.map do |res|
        { id: res[:id], label: res[:term], active: res.fetch(:active, true) }.with_indifferent_access
      end
    end

    def find(id)
      terms.find { |term| term[:id] == id } || {}
    end

    private

      def terms
        subauthority_hash = YAML.load(File.read(subauthority_filename))
        terms = subauthority_hash.with_indifferent_access.fetch(:terms, [])
        normalize_terms(terms)
      end

      def subauthority_filename
        File.join(Local.subauthorities_path, "#{subauthority}.yml")
      end

      def normalize_terms(terms)
        terms.map do |term|
          if term.is_a? String
            { id: term, term: term }.with_indifferent_access
          else
            term[:id] ||= term[:term]
            term
          end
        end
      end
  end
end
