require 'curl'

module Qa::Authorities
  class Base

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

  end
end
