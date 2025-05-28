# This module loads linked data authorities and provides access to their configurations.
module Qa
  module LinkedData
    class AuthorityService
      def self.load_authorities
        load_linked_data_config
      end

      # Load or reload the linked data configuration files
      def self.load_linked_data_config
        ld_auth_cfg = {}
        # Linked data settings
        Dir[File.join(Qa::Engine.root, 'config', 'authorities', 'linked_data', '*.json')].each do |fn|
          process_config_file(file_path: fn, config_hash: ld_auth_cfg)
        end
        # Optional local (app) linked data settings overrides
        Dir[Rails.root.join('config', 'authorities', 'linked_data', '*.json')].each do |fn|
          process_config_file(file_path: fn, config_hash: ld_auth_cfg)
        end
        Qa.config.linked_data_authority_configs = ld_auth_cfg
      end

      # load settings into a configuration hash:
      def self.process_config_file(file_path:, config_hash:)
        file_key = File.basename(file_path, '.json').upcase.to_sym
        json = File.read(File.expand_path(file_path, __FILE__))
        cfg = JSON.parse(json).deep_symbolize_keys
        config_hash[file_key] = cfg
      end

      # Get the list of names of the loaded authorities
      # @return [Array<String>] all loaded authority configurations
      def self.authority_configs
        Qa.config.linked_data_authority_configs
      end

      # Get the configuration for an authority
      # @param [String] name of the authority
      # @return [Hash] configuration for the specified authority
      def self.authority_config(authname)
        authority_configs[authname]
      end

      # Get the list of names of the loaded authorities
      # @return [Array<String>] names of the authority config files that are currently loaded
      def self.authority_names
        authority_configs.keys.sort
      end

      # Get the list of names and details of the loaded authorities
      # @return [Array<String>] names of the authority config files that are currently loaded
      def self.authority_details
        details = []
        authority_names.each { |auth_name| details << Qa::Authorities::LinkedData::Config.new(auth_name).authority_info }
        details.flatten
      end
    end
  end
end
