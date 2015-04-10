require 'uri'

module Qa::Authorities
  module Loc
    extend AuthorityWithSubAuthority

    require 'qa/authorities/loc/generic_authority'
    def self.subauthority_for(sub_authority)
      validate_sub_authority!(sub_authority)
      GenericAuthority.new(sub_authority)
    end

    extend LocSubauthority
    def self.sub_authorities
      authorities + vocabularies + datatypes + preservation
    end
  end
end
