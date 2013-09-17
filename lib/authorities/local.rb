module Authorities
  
  class Local
    
    attr_accessor :response
    
    def initialize(q, authority)
      self.response = []
      terms = YAML.load(File.read(File.join(Rails.root, 'config', 'authorities', "#{authority}.yml")))
      if q.blank?
        self.response = terms
      end
    end

    def results
      self.response.to_json
    end
    
  end
  
end