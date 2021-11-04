module Qa::Authorities
  class Local::FileBasedAuthority < Base
    attr_reader :subauthority
    def initialize(subauthority)
      @subauthority = subauthority
    end

    def search(q)
      r = q.blank? ? [] : terms.select { |term| /\b#{q.downcase}/.match(term[:term].downcase) }
      r.map do |res|
        { id: res[:id], label: res[:term], uri: res.fetch(:uri, nil) }.compact.with_indifferent_access
      end
    end

    def all
      terms.map do |res|
        { id: res[:id], label: res[:term], active: res.fetch(:active, true), uri: res.fetch(:uri, nil) }
          .compact.with_indifferent_access
      end
    end

    def find(id)
      terms.find { |term| term[:id] == id } || {}
    end

    private

      def terms
        subauthority_hash = YAML.load(File.read(subauthority_filename)) # rubocop:disable Security/YAMLLoad # TODO: Explore how to change this to safe_load.  Many tests fail when making this change.
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
