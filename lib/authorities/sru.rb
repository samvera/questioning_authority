require 'open-uri'
require 'nokogiri'

module Authorities

  class SRU
    attr_accessor :response

    def initialize q
      sru_xml_response = Nokogiri::XML(open("http://tspilot.oclc.org/mesh/?query=oclcts.rootHeading+exact+%22" + q + "*%22&version=1.1&operation=searchRetrieve&recordSchema=http%3A%2F%2Fzthes.z3950.org%2Fxml%2F1.0%2F&maximumRecords=10&startRecord=1&resultSetTTL=300&recordPacking=xml&recordXPath=&sortKeys="))
      r = Array.new
      sru_xml_response.xpath('sru:searchRetrieveResponse/sru:records/sru:record/sru:recordData', 'sru' => 'http://www.loc.gov/zing/srw/').each do |record|
        r.append({"id" => record.xpath('Zthes/term/termId').first.content, "label" => record.xpath('Zthes/term/termName').first.content})
      end
      self.response = r.to_json
    end
    
    def results
      self.response[1].to_json
    end
  end
end
