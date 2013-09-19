require 'nokogiri'
require 'json'

module Authorities
  class Tgnlang
    attr_accessor :response, :raw_response
    def initialize(q,sub_authority='')
      self.raw_response = getTgnLang(q)
    end

    def getTgnLang(q)
      str = "lib/data/TGN_LANGUAGES.xml"
      doc = Nokogiri::XML(File.open(str))
      size = doc.css("Language_Name").size
      i=0
      lang_array = Array.new
      while i < size do
        lang_hash = Hash.new
        lang_hash["id"] = doc.css("Language_Code")[i].text
        lang_hash["label"] = doc.css("Language_Name")[i].text
        lang_array.push(lang_hash)
        i+=1
      end
      obj = Array.new      
      lang_array.each do |h|
        if h["label"].downcase.start_with?(q.downcase)  
          obj.push(h)
        end
      end
      obj.to_json
    end

    def results
      self.raw_response
    end
    def parse_authority_response
      self.raw_response
    end
  end
end
