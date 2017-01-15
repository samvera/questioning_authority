require 'deprecation'

module Qa::Authorities
  ##
  # @abstract The base class for all authorites. Implementing subclasses must
  #   provide {#all} and #{find} methods.
  # @todo What about {#search}?
  class Base
    extend Deprecation

    ##
    # @abstract By default, #all is not implemented. A subclass authority must
    #   implement this method to conform to the generic interface.
    #
    # @return [Enumerable]
    # @todo better specify return type
    def all
    end

    ##
    # @abstract By default, #find is not implemented. A subclass authority must
    #   implement this method to conform to the generic interface.
    #
    # @param id [String] the id string for the authority to lookup
    #
    # @return [Hash]
    # @todo better specify return type
    def find(_id)
    end

    ##
    # @deprecated use {#find} instead
    def full_record(id, _subauthority = nil)
      Deprecation.warn('#full_record is deprecated. Use #find instead')
      find(id)
    end
  end
end
