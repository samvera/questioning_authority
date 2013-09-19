require 'open-uri'
require 'nokogiri'

module Authorities

  class Oclcts < Authorities::Base
  
    SRU_SERVER_CONFIG = YAML.load_file(Rails.root.join("config", "oclcts-authorities.yml"))
    
    attr_accessor :sub_authority

    def initialize(q, sub_authority='')
      self.sub_authority = sub_authority
      self.query_url = SRU_SERVER_CONFIG["url-pattern"]["prefix-query"].gsub(/\{query\}/, q).gsub(/\{authority\-id\}/, sub_authority)
      self.raw_response = Nokogiri::XML(open(self.query_url))
    end

    def self.authority_valid?(sub_authority)
      sub_authorities.include?(sub_authority)
    end

    def self.sub_authorities
      a = []
      SRU_SERVER_CONFIG["authorities"].each do | sub_authority |
        a.append(sub_authority[0])
      end
      a
    end

    def parse_authority_response
      r = Array.new
      self.raw_response.xpath('sru:searchRetrieveResponse/sru:records/sru:record/sru:recordData', 'sru' => 'http://www.loc.gov/zing/srw/').each do |record|
        r.append({"id" => record.xpath('Zthes/term/termId').first.content, "label" => record.xpath('Zthes/term/termName').first.content})
      end
      self.response = r
    end

    def get_full_record(id)
      unless self.raw_response.xpath("sru:searchRetrieveResponse/sru:records/sru:record/sru:recordData/Zthes/term[termId='" + id + "']", 'sru' => 'http://www.loc.gov/zing/srw/').blank?
        parse_full_record(self.raw_response, id)
      else
        url = SRU_SERVER_CONFIG["url-pattern"]["id-lookup"].gsub(/\{id\}/, id).gsub(/\{authority\-id\}/, self.sub_authority)
        parse_full_record(Nokogiri::XML(open(url)), id)
      end
      
    end
    
    def parse_full_record(raw_xml, id)
      a = {}
      zthes_record = raw_xml.xpath("sru:searchRetrieveResponse/sru:records/sru:record/sru:recordData/Zthes/term[termId='" + id + "']", 'sru' => 'http://www.loc.gov/zing/srw/');
      zthes_record.children.each do | child | 
        if (child.is_a? Nokogiri::XML::Element) && (!child.children.nil?) && (child.children.size == 1) && (child.children.first.is_a? Nokogiri::XML::Text)
          a[child.name] = child.children.first.to_s;    
        end
      end
      a;
    end

    def results
      self.response.to_json
    end
  end
end
