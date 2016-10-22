require 'nokogiri'

module Qa::Authorities
  class Tgnlang < Base
    def search(q)
      get_tgnlang(q)
    end

    def get_tgnlang(q)
      obj = []
      Tgnlang.languages.each do |h|
        obj.push(h) if h["label"].downcase.start_with?(q.downcase)
      end
      obj
    end

    def self.languages
      @languages ||=
        begin
          language_filename = File.expand_path("../../data/TGN_LANGUAGES.xml", __FILE__)
          lang_array = []
          File.open(language_filename) do |f|
            doc = Nokogiri::XML(f)
            lang_array = doc.css("Language").map do |lang|
              id = lang.css("Language_Code").first.text
              label = lang.css("Language_Name").first.text
              { "id" => id, "label" => label }
            end
          end
          lang_array
        end
    end

    def find(id)
      id = id.downcase
      Tgnlang.languages.each do |h|
        return h if h["label"].downcase == id
      end
      {}
    end
  end
end
