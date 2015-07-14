require 'uri'

module Qa::Authorities
  module Getty
    require 'qa/authorities/getty/aat'
    require 'qa/authorities/getty/tgn'
    extend AuthorityWithSubAuthority

    def self.subauthorities
      [ "aat" , "tgn" ]
    end

    def self.subauthority_for(subauthority)
      validate_subauthority!(subauthority)
      if subauthority == 'aat'
        AAT.new(subauthority)
      elsif subauthority == 'tgn'
        TGN.new(subauthority)
      end
    end
  end
end

