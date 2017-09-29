# Defines the external authority predicates used to extract from the graph the values for normalized results fields.
module Qa
  module LinkedData
    module Config
      class ResultsMap
        ID_PREDICATE = :id_predicate
        LABEL_PREDICATE = :label_predicate
        ALTLABEL_PREDICATE = :altlabel_predicate
        SORT_PREDICATE = :sort_predicate
        BROADER_PREDICATE = :broader_predicate
        NARROWER_PREDICATE = :narrower_predicate
        SAMEAS_PREDICATE = :sameas_predicate

        TERM_RESULTS_MAP = :term_results_map
        SEARCH_RESULTS_MAP = :search_results_map

        attr_reader :results_type # [TERM_RESULTS_MAP | SEARCH_RESULTS_MAP] determines which set of predicates are required/optional/not supported

        # @param config [Hash] key = name of qa results field; value = predicate in result graph that has the value for the field
        # @param results_type [Symbol] TERM_RESULTS_MAP or SEARCH_RESULTS_MAP
        def initialize(config: {}, results_type:)
          raise ArgumentError, "label_predicate is required" unless config.key?(LABEL_PREDICATE)
          raise ArgumentError, "results_type must be TERM_RESULTS_MAP | SEARCH_RESULTS_MAP" unless results_type == TERM_RESULTS_MAP || results_type == SEARCH_RESULTS_MAP
          @results_type = results_type
          @results_map = config
        end

        # json result field to predicate mapping that is used to generate the json results to return from a QA request
        def generate_map
          return generate_search_map if @results_type == SEARCH_RESULTS_MAP
          generate_term_map
        end

        # List of predicates to keep in the graph during filtering for results generation.
        def predicates
          return search_predicates if @results_type == SEARCH_RESULTS_MAP
          term_predicates
        end

        private

          # json result field to predicate mapping for search
          def generate_search_map
            map = {}
            map[:uri] = :subject_uri
            map[:id] = id_predicate || :subject_uri # set id to uri if not specified
            map[:label] = label_predicate
            map[:altlabel] = altlabel_predicate if altlabel_predicate
            map[:sort] = sort_predicate || label_predicate # default to alpha sort on label if unspecified
            map
          end

          # json result field to predicate mapping for term
          def generate_term_map
            map = {}
            map[:uri] = :subject_uri
            map[:id] = id_predicate || :subject_uri # set id to uri if not specified
            map[:label] = label_predicate
            map[:altlabel] = altlabel_predicate if altlabel_predicate
            map[:broader] = broader_predicate if broader_predicate
            map[:narrower] = narrower_predicate if narrower_predicate
            map[:sameas] = sameas_predicate if sameas_predicate
            map
          end

          # List of predicates to keep in the graph for search.
          def search_predicates
            preds = []
            preds << id_predicate if id_predicate
            preds << label_predicate
            preds << altlabel_predicate if altlabel_predicate
            preds << sort_predicate if sort_predicate
            preds.uniq
          end

          # List of predicates to keep in the graph for term.
          def term_predicates
            preds = []
            preds << id_predicate if id_predicate
            preds << label_predicate
            preds << altlabel_predicate if altlabel_predicate
            preds << broader_predicate if broader_predicate
            preds << narrower_predicate if narrower_predicate
            preds << sameas_predicate if sameas_predicate
            preds.uniq
          end

          def id_predicate
            @results_map.fetch(ID_PREDICATE, nil)
          end

          def label_predicate
            @results_map.fetch(LABEL_PREDICATE, nil)
          end

          def altlabel_predicate
            @results_map.fetch(ALTLABEL_PREDICATE, nil)
          end

          def sort_predicate
            @results_map.fetch(SORT_PREDICATE, nil)
          end

          def broader_predicate
            @results_map.fetch(BROADER_PREDICATE, nil)
          end

          def narrower_predicate
            @results_map.fetch(NARROWER_PREDICATE, nil)
          end

          def sameas_predicate
            @results_map.fetch(SAMEAS_PREDICATE, nil)
          end
      end
    end
  end
end
