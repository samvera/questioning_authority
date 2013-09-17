module Authorities
  
  class Local
    
    attr_accessor :response
    
    def initialize(q, sub_authority)
      terms = YAML.load(File.read(File.join(Rails.root, AUTHORITIES_CONFIG[:local_path], "#{sub_authority}.yml")))[:terms]
      if q.blank?
        self.response = terms
      else
        sub_terms = []
        terms.each { |term| sub_terms << term if term[:label].start_with?(q) }
        self.response = sub_terms
      end
    end

    def results
      self.response.to_json
    end
    
    def sub_authorities
      sub_auths = []
      Dir.foreach(File.join(Rails.root, AUTHORITIES_CONFIG[:local_path])) { |file| sub_auths << File.basename(file, File.extname(file)) }
      sub_auths
    end
        
  end
  
end