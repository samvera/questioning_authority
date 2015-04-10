require 'uri'

module Qa::Authorities
  module Getty
    require 'qa/authorities/getty/aat'
    extend AuthorityWithSubAuthority

    def self.subauthorities
      [ "AAT" ]
    end
  end
end

