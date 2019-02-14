# Provide service for mapping predicates to object values.
module Qa
  module LinkedData
    module Mapper
      class ContextMapperService
        class_attribute :graph_service
        self.graph_service = Qa::LinkedData::GraphService

        class << self
          # Extract predicates specified in the predicate_map from the graph and return as a value map for a single subject URI.
          # @param graph [RDF::Graph] the graph from which to extract result values
          # @param context_map [Qa::LinkedData::Config::ContextMap] defines properties to extract from the graph to provide additional context
          # @param subject_uri [RDF::URI] the subject within the graph for which the values are being extracted
          # @return [<Hash<Symbol><Array<Object>>] mapped context values and information with hash of map key = array of object values for predicates identified in predicate_map.
          # @example returned context map with one property defined
          #   [{"group" => "group label,
          #     "property" => "property label",
          #     "values" => ["value 1","value 2"],
          #     "selectable" => true,
          #     "drillable" => false}]
          def map_context(graph:, context_map:, subject_uri:)
            context = []
            context_map.properties.each do |property_map|
              values = property_map.values(graph, subject_uri)
              next if values.blank?
              context << construct_context(context_map, property_map, values)
            end
            context
          end

          private

            def construct_context(context_map, property_map, values)
              property_info = {}
              property_info["group"] = context_map.group_label(property_map.group_id) if property_map.group? # TODO: should be group label
              property_info["property"] = property_map.label
              property_info["values"] = values
              property_info["selectable"] = property_map.selectable?
              property_info["drillable"] = property_map.drillable?
              property_info
            end
        end
      end
    end
  end
end
