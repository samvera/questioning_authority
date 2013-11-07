require 'open-uri'
require 'nokogiri'

module Qa::Authorities
  class Oclcts < Qa::Authorities::Base
  
    SRU_SERVER_CONFIG = YAML.load_file(Rails.root.join("config", "oclcts-authorities.yml"))
    
    attr_accessor :sub_authority

    def initialize
    end

    def self.authority_valid?(sub_authority)
      self.sub_authorities.include?(sub_authority)
    end

    def self.sub_authorities
      @sub_authorities ||= SRU_SERVER_CONFIG["authorities"].map { |sub_authority| sub_authority[0] }
    end

    def search(q, sub_authority=nil)
      raw_response = get_raw_response("prefix-query", q, sub_authority)
      r = Array.new
      raw_response.xpath('sru:searchRetrieveResponse/sru:records/sru:record/sru:recordData', 'sru' => 'http://www.loc.gov/zing/srw/').each do |record|
        r.append({"id" => record.xpath('Zthes/term/termId').first.content, "label" => record.xpath('Zthes/term/termName').first.content})
      end
      r
    end

    def get_full_record(id, sub_authority)
      raw_response = get_raw_response("id-lookup", id, sub_authority)
      parse_full_record(raw_response, id)
    end

    def parse_full_record(raw_xml, id)
      a = {}
      zthes_record = raw_xml.xpath("sru:searchRetrieveResponse/sru:records/sru:record/sru:recordData/Zthes/term[termId='#{id}']", 'sru' => 'http://www.loc.gov/zing/srw/')
      zthes_record.children.each do |child|
        if (child.is_a? Nokogiri::XML::Element) && (!child.children.nil?) && (child.children.size == 1) && (child.children.first.is_a? Nokogiri::XML::Text)
          a[child.name] = child.children.first.to_s
        end
      end
      a
    end

    def get_raw_response(query_type, id, sub_authority)
      query_url = SRU_SERVER_CONFIG["url-pattern"][query_type].gsub("{query}", id).gsub("{id}", id).gsub("{authority-id}", sub_authority)
      Nokogiri::XML(open(query_url))
    end
  end
end
