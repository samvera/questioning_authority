# Defines the external authority predicates used to extract from the graph the values for normalized results fields.
module Qa
  module LinkedData
    module Config
      class SearchResultsMap < Qa::LinkedData::Config::ResultsMap
        protected

          # json result field to predicate mapping that is used to generate the json results to return from a QA request
          def extract_map
            generate_search_map
          end

          # List of predicates to keep in the graph during filtering for results generation.
          def extract_predicates_list
            search_predicates
          end

          # json result field to predicate mapping for search
          def generate_search_map
            map = {}
            map[:uri] = :subject_uri
            map[:id] = @id_predicate || :subject_uri # set id to uri if not specified
            map[:label] = @label_predicate
            map[:altlabel] = @altlabel_predicate if @altlabel_predicate
            map[:sort] = @sort_predicate || @label_predicate # default to alpha sort on label if unspecified
            map
          end

          # List of predicates to keep in the graph for search.
          def search_predicates
            preds = []
            preds << @id_predicate if @id_predicate
            preds << @label_predicate
            preds << @altlabel_predicate if @altlabel_predicate
            preds << @sort_predicate if @sort_predicate
            preds.uniq
          end
      end
    end
  end
end
