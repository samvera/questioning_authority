module Qa::Authorities
  class Oclcts::GenericOclcAuthority < Base
    attr_reader :subauthority

    def initialize(subauthority)
      @subauthority = subauthority
    end
    include WebServiceBase

    def search(q)
      get_raw_response("prefix-query", q)
      r = []
      raw_response.xpath('sru:searchRetrieveResponse/sru:records/sru:record/sru:recordData', 'sru' => 'http://www.loc.gov/zing/srw/').each do |record|
        r.append("id" => record.xpath('Zthes/term/termId').first.content, "label" => record.xpath('Zthes/term/termName').first.content)
      end
      r
    end

    def find(id)
      get_raw_response("id-lookup", id)
      parse_full_record(id)
    end

    private

      def parse_full_record(id)
        a = {}
        zthes_record = raw_response.xpath("sru:searchRetrieveResponse/sru:records/sru:record/sru:recordData/Zthes/term[termId='#{id}']", 'sru' => 'http://www.loc.gov/zing/srw/')
        zthes_record.children.each do |child|
          if (child.is_a? Nokogiri::XML::Element) && !child.children.nil? && (child.children.size == 1) && (child.children.first.is_a? Nokogiri::XML::Text)
            a[child.name] = child.children.first.to_s
          end
        end
        a
      end

      def get_raw_response(query_type, id)
        query_url = Oclcts.url_pattern(query_type).gsub("{query}", id).gsub("{id}", id).gsub("{authority-id}", subauthority)
        @raw_response = Nokogiri::XML(open(query_url))
      end
  end
end
