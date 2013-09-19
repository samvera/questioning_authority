module Qa::Authorities

  class Local < Qa::Authorities::Base

    attr_accessor :response

    def self.sub_authorities_path
      config_path = AUTHORITIES_CONFIG[:local_path]
      if config_path.starts_with?(File::Separator)
        return config_path
      end
      File.join(Rails.root, config_path)
    end

    def self.sub_authorities
      @sub_auths ||=
        begin
          sub_auths = []
          Dir.foreach(self.sub_authorities_path) { |file| sub_auths << File.basename(file, File.extname(file)) }
          sub_auths
        end
    end

    def self.terms(sub_authority)
      @terms = {} if @terms.nil?
      return @terms[sub_authority] if @terms.has_key?(sub_authority)
      sub_authority_hash =
        begin
          YAML.load(File.read(File.join(self.sub_authorities_path, "#{sub_authority}.yml")))
        rescue
          {}
        end
      @terms[sub_authority] = normalize_terms(sub_authority_hash.fetch(:terms, []))
    end

    def self.normalize_terms(terms)
      terms.map do |term|
        if term.is_a? String
          { :id => term, :term => term }
        else
          term[:id] ||= term[:term]
          term
        end
      end
    end

    def initialize
    end

    def search(q, sub_authority=nil)
      @terms = Local.terms(sub_authority)
      r = q.blank? ? @terms : @terms.select { |term| term[:term].downcase.start_with?(q.downcase) }
      self.response = r.map do |res|
        { :id => res[:id], :label => res[:term] }
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
