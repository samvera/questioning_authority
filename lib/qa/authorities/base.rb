require 'deprecation'

module Qa::Authorities
  class Base
    extend Deprecation

    # By default, #all is not implemented.
    # If the subclassed authority does have this feature
    # then you will overide the #all method in the subclassed authority.
    # TODO: need to set some kind of error here
    def all
    end

    # By default, #find is not implemented.
    # If the subclassed authority does have this feature
    # then you will overide the #find method in the subclassed authority.
    # TODO: need to set some kind of error here
    def find id
    end

    def full_record id, sub_authority=nil
      Deprecation.warn(".full_record is deprecated. Use .find instead")
      find(id)
    end

  end
end
