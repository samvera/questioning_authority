require 'open-uri'
require 'nokogiri'

module Qa::Authorities
  module Oclcts
    require 'qa/authorities/oclcts/generic_oclc_authority'
    extend AuthorityWithSubAuthority

    def self.factory(sub_authority)
      validate_sub_authority!(sub_authority)
      GenericOclcAuthority.new(sub_authority)
    end

    SRU_SERVER_CONFIG = YAML.load_file(Rails.root.join("config", "oclcts-authorities.yml"))

    def self.sub_authorities
      SRU_SERVER_CONFIG["authorities"].map { |sub_authority| sub_authority[0] }
    end

    def self.url_pattern(query_type)
      SRU_SERVER_CONFIG["url-pattern"][query_type]
    end

  end
end
