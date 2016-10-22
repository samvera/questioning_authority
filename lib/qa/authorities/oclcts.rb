require 'open-uri'
require 'nokogiri'

module Qa::Authorities
  module Oclcts
    require 'qa/authorities/oclcts/generic_oclc_authority'
    extend AuthorityWithSubAuthority

    def self.subauthority_for(subauthority)
      validate_subauthority!(subauthority)
      GenericOclcAuthority.new(subauthority)
    end

    SRU_SERVER_CONFIG = YAML.load_file(Rails.root.join("config", "oclcts-authorities.yml"))

    def self.subauthorities
      SRU_SERVER_CONFIG["authorities"].map { |subauthority| subauthority[0] }
    end

    def self.url_pattern(query_type)
      SRU_SERVER_CONFIG["url-pattern"][query_type]
    end
  end
end
