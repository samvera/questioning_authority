module Qa::Authorities
  # Provide authority namespace
  module AssignFast
    extend AuthorityWithSubAuthority
    extend AssignFastSubauthority

    require 'qa/authorities/assign_fast/generic_authority'
    # Create an authority object for given subauthority
    #
    # @param [String] subauthority to use
    # @return [GenericAuthority]
    def self.subauthority_for(subauthority)
      validate_subauthority!(subauthority)
      GenericAuthority.new(subauthority)
    end
  end
end
