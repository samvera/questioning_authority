# Defines the external authority predicates used to extract from the graph the values for normalized results fields.
module Qa
  module LinkedData
    module Config
      class TermResultsMap < Qa::LinkedData::Config::ResultsMap
        private

          # json result field to predicate mapping that is used to generate the json results to return from a QA request
          def extract_map
            generate_term_map
          end

          # List of predicates to keep in the graph during filtering for results generation.
          def extract_predicates_list
            term_predicates
          end

          # json result field to predicate mapping for term
          def generate_term_map
            map = {}
            map[:uri] = :subject_uri
            map[:id] = @id_predicate || :subject_uri # set id to uri if not specified
            map[:label] = @label_predicate
            map[:altlabel] = @altlabel_predicate if @altlabel_predicate
            map[:broader] = @broader_predicate if @broader_predicate
            map[:narrower] = @narrower_predicate if @narrower_predicate
            map[:sameas] = @sameas_predicate if @sameas_predicate
            map
          end

          # List of predicates to keep in the graph for term.
          def term_predicates
            preds = []
            preds << @id_predicate if @id_predicate
            preds << @label_predicate
            preds << @altlabel_predicate if @altlabel_predicate
            preds << @broader_predicate if @broader_predicate
            preds << @narrower_predicate if @narrower_predicate
            preds << @sameas_predicate if @sameas_predicate
            preds.uniq
          end
      end
    end
  end
end
