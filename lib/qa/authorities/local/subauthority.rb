module Qa::Authorities
  # This is really just a sub-authority for Local
  class Subauthority
    attr_reader :name
    def initialize(name)
      @name = name
    end

    def terms
      @terms ||= load_sub_authority_terms
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

    def full_record(id)
      terms.find { |term| term[:id] == id } || {}
    end

    class << self
      def sub_authorities_path
        config_path = AUTHORITIES_CONFIG[:local_path]
        if config_path.starts_with?(File::Separator)
          return config_path
        end
        File.join(Rails.root, config_path)
      end

      def names
        @sub_auth_names ||=
          begin
            sub_auths = []
            Dir.foreach(sub_authorities_path) { |file| sub_auths << File.basename(file, File.extname(file)) }
            sub_auths
          end
      end
    end

    private
      def load_sub_authority_terms
        sub_authority_hash = YAML.load(File.read(sub_authority_filename))
        terms = sub_authority_hash.with_indifferent_access.fetch(:terms, [])
        normalize_terms(terms)
      end

      def sub_authority_filename
        File.join(self.class.sub_authorities_path, "#{name}.yml")
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
