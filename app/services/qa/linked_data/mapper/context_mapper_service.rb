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
              populated_property_map = populate_property_map(context_map, property_map, graph, subject_uri)
              next if populated_property_map.blank?
              context << populated_property_map
            end
            context
          end

          private

            def populate_property_map(context_map, property_map, graph, subject_uri)
              begin
                values = property_values(property_map, graph, subject_uri)
              rescue => e
                values = Qa::LinkedData::Config::ContextPropertyMap::VALUE_ON_ERROR
                error = e.message
              end
              return {} if values.blank? && property_map.optional?
              property_info(values, error, context_map, property_map)
            end

            def property_info(values, error, context_map, property_map)
              property_info = {}
              property_info["group"] = context_map.group_label(property_map.group_id) if property_map.group?
              property_info["property"] = property_map.label
              property_info["values"] = values
              property_info["selectable"] = property_map.selectable?
              property_info["drillable"] = property_map.drillable?
              property_info["error"] = error if error.present?
              property_info
            end

            def property_values(property_map, graph, subject_uri)
              return property_map.expanded_values(graph, subject_uri) if property_map.expand_uri?
              property_map.values(graph, subject_uri)
            end
        end
      end
    end
  end
end
