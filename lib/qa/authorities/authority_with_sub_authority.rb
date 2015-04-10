module Qa::Authorities
  module AuthorityWithSubAuthority

    # Registers the authority and its sub-authority if it has one
    def new(sub_authority=nil)
      raise "Initializing with as sub authority is removed. use #{self.class}.subauthority_for(#{sub_authority.inspect}) instead"
    end

    def subauthority_for(sub_authority)
      validate_sub_authority!(sub_authority)
      [self, sub_authority].join('::').classify.constantize.new
    end

    def validate_sub_authority!(sub_authority)
      raise Qa::InvalidSubAuthority, "Unable to initialize sub-authority #{sub_authority} for #{self}. Valid sub-authorities are #{sub_authorities.inspect}" unless sub_authorities.include?(sub_authority)
    end

    # By default, an authority has no subauthorities unless they
    # are defined by the subclassed authority.
    def sub_authorities
      []
    end
  end
end
