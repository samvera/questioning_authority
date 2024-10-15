module Qa::Authorities
  module LinkedData
    # A wrapper around configured linked data authorities for use with questioning_authority.  The search and find methods
    # can be called directly from an instance of this class.  The Qa::LinkedDataTermsController uses these methods to provide
    # a URL based API for searching and term retrieval.
    #
    # @see Qa::Authorities::LinkedData::SearchQuery#search
    # @see Qa::Authorities::LinkedData::FindTerm#find
    # @see Qa::LinkedDataTermsController#search
    # @see Qa::LinkedDataTermsController#show
    # @see Qa::Authorities::LinkedData::Config
    class GenericAuthority < Base
      attr_reader :authority_config
      private :authority_config

      self.linked_data = true

      delegate :supports_term?, :term_subauthorities?, :term_subauthority?,
               :term_id_expects_uri?, :term_id_expects_id?, to: :term_config

      delegate :supports_search?, to: :search_config
      delegate :subauthority?, :subauthorities?, to: :search_config, prefix: 'search'

      def initialize(auth_name)
        super()
        @authority_config = Qa::Authorities::LinkedData::Config.new(auth_name)
      end

      def reload_authorities
        @authorities_service.load_authorities
      end

      def authorities_service
        @authorities_service ||= Qa::LinkedData::AuthorityService
      end

      def search_service
        @search_service ||= Qa::Authorities::LinkedData::SearchQuery.new(search_config)
      end

      def item_service
        @item_service ||= Qa::Authorities::LinkedData::FindTerm.new(term_config)
      end

      delegate :search, to: :search_service
      delegate :find, to: :item_service
      delegate :load_authorities, :authority_names, to: :authorities_service

      private

        def search_config
          authority_config.search
        end

        def term_config
          authority_config.term
        end
    end
  end
end
