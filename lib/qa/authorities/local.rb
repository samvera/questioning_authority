module Qa::Authorities

  class Local < Qa::Authorities::Base

    attr_accessor :response

    class << self

      def sub_authorities_path
        config_path = AUTHORITIES_CONFIG[:local_path]
        if config_path.starts_with?(File::Separator)
          return config_path
        end
        File.join(Rails.root, config_path)
      end

      def sub_authorities
        @sub_auths ||=
          begin
            sub_auths = []
            Dir.foreach(sub_authorities_path) { |file| sub_auths << File.basename(file, File.extname(file)) }
            sub_auths
          end
      end

      def terms(sub_authority)
        @terms = {} if @terms.nil?
        return @terms[sub_authority] if @terms.has_key?(sub_authority)
        load_sub_authority_terms(sub_authority)
      end

      private
        def load_sub_authority_terms(sub_authority)
          sub_authority_hash = YAML.load(File.read(sub_authority_filename(sub_authority)))
          terms = sub_authority_hash.with_indifferent_access.fetch(:terms, [])
          @terms[sub_authority] = normalize_terms(terms)
        end

        def sub_authority_filename(sub_authority)
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

    def initialize
    end

    def search(q, sub_authority=nil)
      @terms = Local.terms(sub_authority)
      r = q.blank? ? @terms : @terms.select { |term| term[:term].downcase.start_with?(q.downcase) }
      self.response = r.map do |res|
        { :id => res[:id], :label => res[:term] }.with_indifferent_access
      end
    end

    def get_full_record(id, sub_authority=nil)
      @terms = Local.terms(sub_authority)
      @terms.each do |term|
        return term if term[:id] == id
      end
      return {}
    end

  end
end
