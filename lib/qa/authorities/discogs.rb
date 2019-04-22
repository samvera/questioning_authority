module Qa::Authorities
  # Provide authority namespace
  module Discogs
    extend ActiveSupport::Autoload
    autoload :GenericAuthority
    autoload :DiscogsTranslation
    autoload :DiscogsUtils
    autoload :DiscogsWorksBuilder
    autoload :DiscogsInstanceBuilder

    extend AuthorityWithSubAuthority
    extend DiscogsSubauthority

    require 'qa/authorities/discogs/generic_authority'
    # Create an authority object for given subauthority
    #
    # @param [String] subauthority to use
    # @return [GenericAuthority]
    def self.subauthority_for(subauthority)
      validate_subauthority!(subauthority)
      GenericAuthority.new(subauthority)
    end

    def self.subauthorities
      authorities
    end
  end
end
