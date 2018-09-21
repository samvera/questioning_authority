require 'qa/authorities/linked_data/config/term_config'.freeze
require 'qa/authorities/linked_data/config/search_config'.freeze
require 'json'
require 'erb'

# Provide attr_reader methods for linked data authority configurations.  Some default configurations are provided for several
# linked data authorities and can be found at /config/authorities/linked_data.  You can add configurations for new authorities by
# adding the configuration at YOUR_APP/config/authorities/linked_data.  You can modify a QA provided configuration by copying
# it to YOUR_APP/config/authorities/linked_data and making the modifications there. See README for more information on the
# structure of the configuration.
#
# This configuration processed by this class is used by Qa::Authorities::LinkedData::GenericAuthority to drive url construction
# and results processing for a specific linked data authority.
#
# @see Qa::Authorities::LinkedData::GenericAuthority#initialize
# @see Qa::Authorities::LinkedData::TermConfig
# @see Qa::Authorities::LinkedData::SearchConfig
module Qa::Authorities
  module LinkedData
    class Config
      class << self
        include ERB::Util
      end

      attr_reader :authority_name
      attr_reader :authority_config

      # Initialize to hold the configuration for the specifed authority.  Configurations are defined in config/authorities/linked_data.  See README for more information.
      # @param [String] the name of the configuration file for the authority
      # @return [Qa::Authorities::LinkedData::Config] instance of this class
      def initialize(auth_name)
        @authority_name = auth_name
        auth_config
      end

      def search
        @search ||= Qa::Authorities::LinkedData::SearchConfig.new(auth_config.fetch(:search))
      end

      def term
        @term ||= Qa::Authorities::LinkedData::TermConfig.new(auth_config.fetch(:term))
      end

      # Return the full configuration for an authority
      # @return [String] the authority configuration
      def auth_config
        @authority_config ||= Qa::Authorities::LinkedData::AuthorityService.authority_config(@authority_name)
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data authority '#{@authority_name}'" if @authority_config.nil?
        @authority_config
      end

      def self.config_value(config, key)
        return nil if config.nil? || !(config.key? key)
        config[key]
      end

      def self.predicate_uri(config, key)
        pred = config_value(config, key)
        pred_uri = nil
        pred_uri = RDF::URI(pred) unless pred.nil? || pred.length <= 0
        pred_uri
      end

      def self.replace_pattern(url, pattern, value, encode = false)
        value = url_encode(value).gsub(".", "%2E") if encode
        url.gsub("{?#{pattern}}", value)
      end

      def self.process_subauthority(url, subauth_pattern, subauthorities, subauth_key)
        pattern = subauth_pattern[:pattern]
        value = subauthorities[subauth_key] || subauth_pattern[:default]
        replace_pattern(url, pattern, value)
      end

      def self.apply_replacements(url, config, replacements = {})
        return url unless config.size.positive?
        config.each do |param_key, rep_pattern|
          s_param_key = param_key.to_s
          value = replacements[param_key] || replacements[s_param_key] || rep_pattern[:default]
          url = replace_pattern(url, param_key, value, rep_pattern[:encode])
        end
        url
      end
    end
  end
end
