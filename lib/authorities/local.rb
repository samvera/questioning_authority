module Authorities
  
  class Local < Authorities::Base
    
    attr_accessor :response
    
    def initialize(q, sub_authority)
      begin
        sub_authority_hash = YAML.load(File.read(File.join(Authorities::Local.sub_authorities_path, "#{sub_authority}.yml")))
      rescue
        sub_authority_hash = {}
      end
      @terms = normalize_terms(sub_authority_hash.fetch(:terms, []))
      if q.blank?
        self.response = @terms
      else
        sub_terms = []
        @terms.each { |term| sub_terms << term if term[:term].start_with?(q) }
        self.response = sub_terms
      end
    end

    def normalize_terms(terms)
      normalized_terms = []
      terms.each do |term|
        if term.is_a? String
          normalized_terms << { :id => term, :term => term }
        else
          term[:id] = term[:id] || term[:term]
          normalized_terms << term
        end
      end
      normalized_terms
    end

    def parse_authority_response
      parsed_response = []
      self.response.each do |res|
        parsed_response << { :id => res[:id], :label => res[:term] }
      end
      self.response = parsed_response
    end
    
    def get_full_record(id)
      target_term = {}
      @terms.each do |term|
        if term[:id] == id
          target_term = term
        end
      end
      target_term.to_json
    end
    
    def self.sub_authorities_path
      config_path = AUTHORITIES_CONFIG[:local_path]
      if config_path.starts_with?(File::Separator)
        config_path
      else
        File.join(Rails.root, config_path)
      end
    end
    
    def self.sub_authorities
      sub_auths = []
      Dir.foreach(Authorities::Local.sub_authorities_path) { |file| sub_auths << File.basename(file, File.extname(file)) }
      sub_auths
    end
        
  end
  
end