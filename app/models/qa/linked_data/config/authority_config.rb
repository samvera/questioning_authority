# Provide attr_reader methods specific for linked data authority configurations.
module Qa
  module LinkedData
    module Config
      class AuthorityConfig
        attr_reader :authority_name # [Symbol] identifier for the authority (e.g. :OCLC_FAST) (required)
        attr_reader :search_config # [Qa::LinkedData::Config::SearchConfig] configuration model for query searches (optional)
        attr_reader :term_config # [Qa::LinkedData::Config::TermConfig] configuration model for fetching terms (optional)

        # Initialize to hold the configuration for the specifed authority.  Configurations are defined in config/authorities/linked_data (e.g. oclc_fast.json).  See README for more information.
        # @param [Symbol] the identifier of the configuration file for the authority (e.g. :OCLC_FAST)
        # @return [Qa::LinkedData::Config::AuthorityConfig] instance of this class
        def initialize(auth_name)
          config = Qa::LinkedData::AuthorityRegistryService.retrieve(auth_name)
          return config if config.present?

          raw_config = raw_auth_config(auth_name)
          @authority_name = auth_name
          @search_config = Qa::LinkedData::Config::SearchConfig.new(raw_config.fetch(:search, {}))
          @term_config = Qa::LinkedData::Config::TermConfig.new(raw_config.fetch(:term, {}))
          Qa::LinkedData::AuthorityRegistryService.add(self)
        end

        # Does this authority configuration have search defined?
        # @return [Boolean] true if search is configured; otherwise, false
        def supports_search_query?
          @search_config.supports_search_query?
        end
        alias supports_search? supports_search_query?

        # Does this authority configuration have term defined?
        # @return [Boolean] true if term is configured; otherwise, false
        def supports_term_fetch?
          @term_config.supports_term_fetch?
        end
        alias supports_term? supports_term_fetch?

        private

          # Return the full configuration for an authority
          # @param [String] the name of the configuration file for the authority
          # @return [Hash] the full authority configuration hash read from the json configuration file
          def raw_auth_config(auth_name)
            raw_config ||= LINKED_DATA_AUTHORITIES_CONFIG[auth_name]
            raise Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data authority '#{auth_name}'" unless raw_config.present?
            raw_config
          end
      end
    end
  end
end
