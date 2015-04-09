module Qa::Authorities
  module Local
    extend AuthorityWithSubAuthority
    extend Qa::Authorities::LocalSubauthority
    require 'qa/authorities/local/file_based_authority'

    def self.factory(sub_authority)
      validate_sub_authority!(sub_authority)
      FileBasedAuthority.new(sub_authority)
    end

    def self.sub_authorities
      names
    end
  end
end
