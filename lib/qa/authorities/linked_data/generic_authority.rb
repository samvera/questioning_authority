module Qa::Authorities
  module LinkedData
    # A wrapper around configured linked data authorities for use with questioning_authority
    class GenericAuthority < Base
      attr_reader :auth_config

      delegate :search_subauthorities?, :term_subauthorities?, :search_subauthority?, :term_subauthority?,
               :supports_search?, :supports_term?, :term_id_expects_uri?, :term_id_expects_id?, to: :auth_config

      def initialize(auth_name)
        @auth_config = Qa::Authorities::LinkedData::Config.new(auth_name)
      end

      include WebServiceBase
      include Qa::Authorities::LinkedData::RdfHelper
      include Qa::Authorities::LinkedData::FindTerm
      include Qa::Authorities::LinkedData::SearchQuery

      private

        def init_consolidated_hash(consolidated_results, uri, id)
          consolidated_hash = consolidated_results[uri] || {}
          if consolidated_hash.empty?
            consolidated_hash[:id] = uri
            consolidated_hash[:id] = id unless id.nil? || id.length <= 0
          end
          consolidated_hash
        end

        def object_value(stmt_hash, consolidated_hash, name, as_string = true)
          new_object_value = stmt_hash[name]
          new_object_value = new_object_value.to_s if as_string
          all_object_values = consolidated_hash[name] || []
          all_object_values << new_object_value unless new_object_value.nil? || all_object_values.include?(new_object_value)
          all_object_values
        end
    end
  end
end
