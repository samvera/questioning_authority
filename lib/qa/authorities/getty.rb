require 'uri'

module Qa::Authorities
  module Getty
    require 'qa/authorities/getty/aat'
    extend AuthorityWithSubAuthority

    def self.subauthorities
      [ "aat" ]
    end

    def self.subauthority_class(_)
      AAT
    end
  end
end

