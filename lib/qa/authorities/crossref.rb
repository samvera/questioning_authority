require 'uri'
module Qa::Authorities
  module Crossref
    require 'qa/authorities/crossref/generic_authority'
    extend AuthorityWithSubAuthority

    def self.subauthority_for(subauthority)
      validate_subauthority!(subauthority)
      GenericAuthority.new(subauthority)
    end

    def self.subauthorities
      ['funders', 'journals']
    end
  end
end
