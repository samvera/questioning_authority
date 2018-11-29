require 'rdf'

# Encapsulates processing of RDF results returned by the linked data authority.  This is used exclussively by Qa::Authorities::LinkedData::GenericAuthority
# @see Qa::Authorities::LinkedData::GenericAuthority
module Qa::Authorities
  module LinkedData
    module RdfHelper
      private

        # TODO: elr - The bulk of the methods in this class moved to app/services/linked_data/rdf_service.rb.  The remaining
        # methods are expected to move in a later refactor.

        def object_value(stmt_hash, consolidated_hash, name, as_string = true)
          new_object_value = stmt_hash[name]
          new_object_value = new_object_value.to_s if as_string
          all_object_values = consolidated_hash[name] || []
          all_object_values << new_object_value unless new_object_value.nil? || all_object_values.include?(new_object_value)
          all_object_values
        end

        def init_consolidated_hash(consolidated_results, uri, id)
          consolidated_hash = consolidated_results[uri] || {}
          if consolidated_hash.empty?
            consolidated_hash[:id] = uri
            consolidated_hash[:id] = id unless id.nil? || id.length <= 0
          end
          consolidated_hash
        end

        def extract_preds(graph, preds)
          RDF::Query.execute(graph) do
            preds[:required].each do |key, pred|
              pattern([:uri, pred, key])
            end
            preds[:optional].each do |key, pred|
              pattern([:uri, pred, key], optional: true)
            end
          end
        end

        def sort_string_by_language(str_literals)
          return str_literals if str_literals.nil? || str_literals.size <= 0
          str_literals.sort! { |a, b| a.language <=> b.language }
          str_literals.collect!(&:to_s)
          str_literals.uniq!
          str_literals.delete_if { |s| s.nil? || s.length <= 0 }
        end
    end
  end
end
