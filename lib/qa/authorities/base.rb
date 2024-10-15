module Qa::Authorities
  ##
  # @abstract The base class for all authorites. Implementing subclasses must
  #   provide {#all} and #{find} methods.
  # @todo What about {#search}?
  class Base
    ##
    # @abstract By default, #all is not implemented. A subclass authority must
    #   implement this method to conform to the generic interface.
    #
    # @return [Enumerable]
    # @raise [NotImplementedError] when this method is abstract.
    #
    # @todo better specify return type
    def all
      raise NotImplementedError, "#{self.class}#all is unimplemented."
    end

    ##
    # @abstract By default, #find is not implemented. A subclass authority must
    #   implement this method to conform to the generic interface.
    #
    # @param id [String] the id string for the authority to lookup
    #
    # @return [Hash]
    # @raise [NotImplementedError] when this method is abstract.
    #
    # @todo better specify return type
    def find(_id)
      raise NotImplementedError, "#{self.class}#find is unimplemented."
    end

    class_attribute :linked_data, instance_writer: false
    self.linked_data = false
  end
end
