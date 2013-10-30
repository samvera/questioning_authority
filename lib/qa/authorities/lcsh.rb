require 'uri'

module Qa::Authorities
  class Lcsh < Qa::Authorities::WebServiceBase

    def initialize
      super
    end

    def search(q, sub_authority='')
      query_url = "http://id.loc.gov/authorities/suggest/?q=" + q
      json_terms = get_json(query_url)
      self.response = build_response(json_terms)
    end

    def get_full_record(id, sub_authority)
    end

    private

    def build_response(json_response)
      a = Array.new
      suggests = json_response[1].each
      urls = json_response[3].each
      loop do
        begin
          a << {"id"=>get_id_from_url(urls.next), "label"=>suggests.next }
        rescue StopIteration
          break
        end
      end
      self.response = a
    end

    def get_id_from_url(url)
      uri = URI(url)
      return uri.path.split('/').last
    end

  end
end
