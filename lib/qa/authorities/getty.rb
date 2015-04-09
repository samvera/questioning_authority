require 'uri'

module Qa::Authorities
  module Getty
    require 'qa/authorities/getty/aat'
    extend AuthorityWithSubAuthority

    def self.sub_authorities
      [ "AAT" ]
    end
  end
end

