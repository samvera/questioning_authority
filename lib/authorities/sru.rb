require 'open-uri'
require 'nokogiri'

module Authorities

  class SRU
  
    SRU_SERVER_CONFIG = YAML.load_file(Rails.root.join("config", "sru-authorities.yml"))
    
    attr_accessor :response, :query_url

    def initialize(q, sub_authority='')
      self.query_url = SRU_SERVER_CONFIG["authorities"][sub_authority]["url"].gsub(/\{query\}/, q)
      sru_xml_response = Nokogiri::XML(open(self.query_url))
      self.response = parse_authority_response(sru_xml_response)
    end

    def valid?(sub_authority)
      sub_authorities.include?(sub_authority)
    end

    def sub_authorities
      a = Array.new
      SRU_SERVER_CONFIG["authorities"].each do | sub_authority |
        a.append(sub_authority[0])
      end
      a
    end

    def parse_authority_response(raw_response)
      r = Array.new
      raw_response.xpath('sru:searchRetrieveResponse/sru:records/sru:record/sru:recordData', 'sru' => 'http://www.loc.gov/zing/srw/').each do |record|
        r.append({"id" => record.xpath('Zthes/term/termId').first.content, "label" => record.xpath('Zthes/term/termName').first.content})
      end
      r
    end

    def results
      self.response.to_json
    end
  end
end
