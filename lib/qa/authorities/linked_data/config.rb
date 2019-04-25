require 'qa/authorities/linked_data/config/term_config'.freeze
require 'qa/authorities/linked_data/config/search_config'.freeze
require 'json'

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
      attr_reader :authority_name

      # Initialize to hold the configuration for the specifed authority.  Configurations are defined in config/authorities/linked_data.  See README for more information.
      # @param [String] the name of the configuration file for the authority
      # @return [Qa::Authorities::LinkedData::Config] instance of this class
      def initialize(auth_name)
        @authority_name = auth_name
        authority_config
      end

      def search
        @search ||= Qa::Authorities::LinkedData::SearchConfig.new(authority_config.fetch(:search), prefixes, self)
      end

      def term
        @term ||= Qa::Authorities::LinkedData::TermConfig.new(authority_config.fetch(:term), prefixes, self)
      end

      def prefixes
        @prefixes ||= authority_config.fetch(:prefixes, {})
      end

      def config_version
        @config_version ||= authority_config.fetch(:QA_CONFIG_VERSION, '1.0')
      end

      def config_version?(version)
        config_version == version
      end

      # Return the full configuration for an authority
      # @return [String] the authority configuration
      def authority_config
        @authority_config ||= Qa::LinkedData::AuthorityService.authority_config(@authority_name)
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data authority '#{@authority_name}'" if @authority_config.nil?
        convert_1_0_to_2_0 if @authority_config.fetch(:QA_CONFIG_VERSION, '1.0') == '1.0'
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

      private

        def convert_1_0_to_2_0
          convert_1_0_url_to_2_0_url(:search)
          convert_1_0_url_to_2_0_url(:term)
        end

        # @deprecated Update to linked data config version 2.0 instead
        def convert_1_0_url_to_2_0_url(action_key)
          url_template = @authority_config.fetch(action_key, {}).fetch(:url, {}).fetch(:template, "")
          return if url_template.blank?
          Qa.deprecation_warning(msg: "Linked data configuration #{authority_name} has 1.0 version format which is deprecated; update to version 2.0 configuration.")
          @authority_config[action_key][:url][:template] = url_template.gsub("{?", "{")
        end
    end
  end
end
