module Qa::Authorities
  module AuthorityWithSubAuthority

    # Registers the authority and its sub-authority if it has one
    def new(subauthority=nil)
      raise "Initializing with as sub authority is removed. use #{self.class}.subauthority_for(#{subauthority.inspect}) instead"
    end

    def subauthority_for(subauthority)
      validate_subauthority!(subauthority)
      [self, subauthority].join('::').classify.constantize.new
    end

    def validate_subauthority!(subauthority)
      raise Qa::InvalidSubAuthority, "Unable to initialize sub-authority #{subauthority} for #{self}. Valid sub-authorities are #{subauthorities.inspect}" unless subauthorities.include?(subauthority)
    end

    # By default, an authority has no subauthorities unless they
    # are defined by the subclassed authority.
    def subauthorities
      []
    end
  end
end
