require 'deprecation'

module Qa::Authorities
  class Base
    extend Deprecation

    attr_accessor :response

    # Validates any subauthority of a given authority
    def self.authority_valid?(sub_authority)
      sub_authority == nil || sub_authorities.include?(sub_authority)
    end

    # By default, any authority has no subauthorities unless they
    # are defined by the subclassed authority.
    def self.sub_authorities
      []
    end

    # By default, #all is not implemented.
    # If the subclassed authority does have this feature
    # then you will overide the #all method in the subclassed authority.
    # TODO: need to set some kind of error here
    def all sub_authority = nil
    end

  end
end
