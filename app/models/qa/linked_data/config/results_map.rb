# Defines the external authority predicates used to extract from the graph the values for normalized results fields.
module Qa
  module LinkedData
    module Config
      class ResultsMap # ABSTRACT CLASS
        ID_PREDICATE = :id_predicate
        LABEL_PREDICATE = :label_predicate
        ALTLABEL_PREDICATE = :altlabel_predicate
        SORT_PREDICATE = :sort_predicate
        BROADER_PREDICATE = :broader_predicate
        NARROWER_PREDICATE = :narrower_predicate
        SAMEAS_PREDICATE = :sameas_predicate

        attr_reader :predicates # [Array<RDF::URI>] array of the predicates in the results map
        attr_reader :predicate_map # [Hash<Symbol><RDF::URI>] maps json result key to the predicate that holds the value for that key

        # @param map [Hash] key = name of qa results field; value = predicate in result graph that has the value for the field
        # @option map [String] :id_predicate predicate that holds the id of a subject (optional, defaults to subject's uri)
        # @option map [String] :label_predicate predicate that holds the label of a subject (required)
        # @option map [String] :altlabel_predicate predicate that holds the altlabel of a subject (optional)
        # @option map [String] :sort_predicate predicate that holds the value on which to sort search results (search only)
        # @option map [String] :broader_predicate predicate that holds the uris of broader terms of a subject (term only)
        # @option map [String] :narrower_predicate predicate that holds the uris of narrower terms of a subject (term only)
        # @option map [String] :sameas_predicate predicate that holds the uris of terms that are the sameas the subject (term only)
        def initialize(map = {})
          raise ArgumentError, "label_predicate is required" unless map.key?(LABEL_PREDICATE)
          @results_map = map
          extract_predicates(config: map)
          @predicate_map = extract_map
          @predicates = extract_predicates_list
        end

        protected

          # json result field to predicate mapping that is used to generate the json results to return from a QA request
          def extract_map # ABSTRACT METHOD
            raise NoMethodError, 'extract_map is an abstract method and must be implemented by a concrete subclass'
          end

          # List of predicates to keep in the graph during filtering for results generation.
          def extract_predicates_list # ABSTRACT METHOD
            raise NoMethodError, 'extract_predicates_list is an abstract method and must be implemented by a concrete subclass'
          end

          def extract_predicates(config:)
            @id_predicate = extract_predicate(config: config, predicate_key: ID_PREDICATE)
            @label_predicate = extract_predicate(config: config, predicate_key: LABEL_PREDICATE)
            @altlabel_predicate = extract_predicate(config: config, predicate_key: ALTLABEL_PREDICATE)
            @sort_predicate = extract_predicate(config: config, predicate_key: SORT_PREDICATE)
            @broader_predicate = extract_predicate(config: config, predicate_key: BROADER_PREDICATE)
            @narrower_predicate = extract_predicate(config: config, predicate_key: NARROWER_PREDICATE)
            @sameas_predicate = extract_predicate(config: config, predicate_key: SAMEAS_PREDICATE)
          end

          def extract_predicate(config:, predicate_key:)
            predicate = config.fetch(predicate_key, nil)
            RDF::URI(predicate) if predicate.present?
          end
      end
    end
  end
end
