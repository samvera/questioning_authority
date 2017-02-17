require 'qa/authorities/linked_data/config/term_config'.freeze
require 'qa/authorities/linked_data/config/search_config'.freeze

module Qa::Authorities
  module LinkedData
    class Config
      attr_reader :authority_name
      attr_reader :authority_config

      # Initialize to hold the configuration for the specifed authority.  Configurations are defined in config/authorities/linked_data.  See README for more information.
      # @param [String] the name of the configuration file for the authority
      # @return [Qa::Authorities::LinkedData::Config] instance of this class
      def initialize(auth_name)
        @authority_name = auth_name
        auth_config
      end

      include Qa::Authorities::LinkedData::TermConfig
      include Qa::Authorities::LinkedData::SearchConfig

      # Return the full configuration for an authority
      # @return [String] the authority configuration
      def auth_config
        @authority_config ||= LINKED_DATA_AUTHORITIES_CONFIG[@authority_name]
        raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data authority #{@authority_name}" if @authority_config.nil?
        @authority_config
      end

      private

        def config_value(config, key)
          return nil if config.nil? || !(config.key? key)
          config[key]
        end

        def predicate_uri(config, key)
          pred = config_value(config, key)
          pred_uri = nil
          pred_uri = RDF::URI(pred) unless pred.nil? || pred.length <= 0
          pred_uri
        end

        def replacements_config(rep_count, rep_config)
          replacements = {}
          return replacements unless rep_count.positive?
          1.upto(rep_count) do |i|
            rep = rep_config["replacement_#{i}"]
            replacements[rep['param']] = { pattern: rep['pattern'], default: rep['default'] }
          end
          replacements
        end

        def apply_replacements(url, config, replacements = {})
          return url unless config.size.positive?
          config.each do |param_key, rep_pattern|
            pattern = rep_pattern[:pattern]
            value = replacements[param_key] || rep_pattern[:default]
            url = url.gsub(pattern, value)
          end
          url
        end

        def process_subauthority(url, subauth_pattern, subauthorities, subauth_key)
          pattern = subauth_pattern[:pattern]
          value = subauthorities[subauth_key] || subauth_pattern[:default]
          url.gsub(pattern, value)
        end
    end
  end
end
