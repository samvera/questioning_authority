require 'uri'

module Qa::Authorities
  module Getty
    require 'qa/authorities/getty/aat'
    require 'qa/authorities/getty/tgn'
    require 'qa/authorities/getty/ulan'
    extend AuthorityWithSubAuthority

    def self.subauthorities
      ["aat", "tgn", "ulan"]
    end

    def self.subauthority_class(subauthority)
      case subauthority
      when 'aat'
        AAT
      when 'tgn'
        TGN
      when 'ulan'
        Ulan
      end
    end
  end
end
