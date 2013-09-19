require 'curl'

module Qa::Authorities
  class Base
    attr_accessor :response

    def initialize
    end

    # do an autocomplete search
    def search(query, sub_authority=nil)
    end

    # return information on a specific record
    def get_full_record(id, sub_authority=nil)
    end


    def self.authority_valid?(sub_authority)
      sub_authority == nil || sub_authorities.include?(sub_authority)
    end

    def self.sub_authorities
      [] #Overwrite if you have sub_authorities
    end

    # Parse the result from LOC, and return an JSON array of terms that match the query.
    def results
      self.response
    end

    # TODO: there's other info in the self.response that might be worth making access to, such as
    # RDF links, etc.

  end
end
