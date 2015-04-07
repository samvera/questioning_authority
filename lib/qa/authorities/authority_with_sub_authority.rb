module Qa::Authorities
  class AuthorityWithSubAuthority < Base
    attr_reader :sub_authority

    # Registers the authority and its sub-authority if it has one
    def initialize(sub_authority=nil)
      @sub_authority = sub_authority
      raise Qa::MissingSubAuthority, "No sub-authority provided" if sub_authority.nil?
      raise Qa::InvalidSubAuthority, "Unable to initialize sub-authority #{sub_authority} for #{self.class.name}" unless sub_authorities.include?(sub_authority)
    end

    # By default, an authority has no subauthorities unless they
    # are defined by the subclassed authority.
    def sub_authorities
      []
    end
  end
end
