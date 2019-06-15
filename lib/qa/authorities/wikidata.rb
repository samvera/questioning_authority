require 'uri'

module Qa::Authorities
  module Wikidata
    extend ActiveSupport::Autoload
    autoload :GenericAuthority

    extend AuthorityWithSubAuthority

    # require 'qa/authorities/wikidata/generic_authority'
    def self.subauthority_for(subauthority)
      validate_subauthority!(subauthority)
      GenericAuthority.new(subauthority)
    end

    def self.subauthorities
      [
        'item',
        'property',
        'lexeme',
        'form',
        'sense'
      ].freeze
    end
  end
end
