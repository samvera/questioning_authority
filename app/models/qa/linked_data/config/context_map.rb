module Qa
  module LinkedData
    module Config
      class ContextMap
        # Defines the external authority predicates used to extract from the graph additional context values for configuration defined results fields.

        # @param [Hash] map - key = name of qa results field; value = predicate in result graph that has the value for the field
        def initialize(map = {})
          @context_map = map
        end

        def valid?(field_name)
          return false unless field_name.present?
          @context_map.key?(field_name)
        end

        def external_name(qa_field_name)
          raise Qa::InvalidContextField("Requested context field '#{qa_field_name}' is not defined in the context map.") unless valid?(qa_field_name)
          @context_map[qa_field_name]
        end
      end
    end
  end
end
