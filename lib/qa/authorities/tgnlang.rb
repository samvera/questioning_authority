require 'nokogiri'

module Qa::Authorities
  class Tgnlang
    attr_accessor :response
    extend Deprecation

    def initialize
    end

    def search(q, sub_authority='')
      self.response = getTgnLang(q)
    end

    def getTgnLang(q)
      obj = Array.new
      Tgnlang.languages.each do |h|
        if h["label"].downcase.start_with?(q.downcase)
          obj.push(h)
        end
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
              {"id" => id, "label" => label}
            end
          end
          lang_array
        end
    end

    def results
      self.response
    end

    def get_full_record(id, sub_authority)
      Deprecation.warn(Tgnlang, "get_full_record is deprecated and will be removed in 0.1.0. Use full_record instead", caller)
      full_record(id, sub_authority)
    end

    def full_record(id, sub_authority)
      id = id.downcase
      Tgnlang.languages.each do |h|
        if h["label"].downcase == id
          return h
        end
      end
      return {}
    end
  end
end
