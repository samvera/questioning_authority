module Qa::Authorities
  module LinkedData
    module ConfigMerge
      def merge(full_cfg, override_cfg)
        merge_term(full_cfg[:term], override_cfg[:term]) if override_cfg.key? :term
        merge_search(full_cfg[:search], override_cfg[:search]) if override_cfg.key? :search
      end

      def merge_term(full_term, override_term)
        full_term[:term_id] = override_term[:term_id] if override_term.key? :term_id
        full_term[:language] = override_term[:language] if override_term.key? :language
        merge_url(full_term[:url], override_term[:url]) if override_term.key? :url
        merge_reppatterns(full_term[:qa_replacement_patterns], override_term[:qa_replacement_patterns]) if override_term.key? :qa_replacement_patterns
        merge_results(full_term[:results], override_term[:results]) if override_term.key? :results
        merge_subauths(full_term[:subauthorities], override_term[:subauthorities]) if override_term.key? :subauthorities
      end

      def merge_search(full_search, override_search)
        full_search[:language] = override_search[:language] if override_search.key? :language
        merge_url(full_search[:url], override_search[:url]) if override_search.key? :url
        merge_reppatterns(full_search[:qa_replacement_patterns], override_search[:qa_replacement_patterns]) if override_search.key? :qa_replacement_patterns
        merge_results(full_search[:results], override_search[:results]) if override_search.key? :results
        merge_subauths(full_search[:subauthorities], override_search[:subauthorities]) if override_search.key? :subauthorities
      end

      def merge_url(full_url, override_url)
        full_url[:@context] = override_url[:@context] if override_url.key? :@context
        full_url[:@type] = override_url[:@type] if override_url.key? :@type
        full_url[:template] = override_url[:template] if override_url.key? :template
        full_url[:variableRepresentation] = override_url[:variableRepresentation] if override_url.key? :variableRepresentation
        merge_mappings(full_url[:mapping], override_url[:mapping]) if override_url.key? :mapping
      end

      def merge_mappings(full_mappings, override_mappings)
        override_mappings.each do |override_map|
          found = false
          full_mappings.each do |full_map|
            if full_map[:variable] == override_map[:variable]
              merge_variable(full_map, override_map)
              found = true
              break
            end
          end
          full_mappings << override_map unless found
        end
      end

      def merge_variable(full_var, override_var)
        full_var[:@type] = override_var[:@type] if override_var.key? :@type
        full_var[:property] = override_var[:property] if override_var.key? :property
        full_var[:required] = override_var[:required] if override_var.key? :required
        full_var[:default] = override_var[:default] if override_var.key? :default
      end

      def merge_reppatterns(full_patterns, override_patterns)
        full_patterns[:term_id] = override_patterns[:term_id] if override_patterns.key? :term_id
        full_patterns[:query] = override_patterns[:query] if override_patterns.key? :query
        full_patterns[:subauth] = override_patterns[:subauth] if override_patterns.key? :subauth
      end

      def merge_results(full_results, override_results)
        full_results[:id_predicate] = override_results[:id_predicate] if override_results.key? :id_predicate
        full_results[:label_predicate] = override_results[:label_predicate] if override_results.key? :label_predicate
        full_results[:altlabel_predicate] = override_results[:altlabel_predicate] if override_results.key? :altlabel_predicate
        full_results[:broader_predicate] = override_results[:broader_predicate] if override_results.key? :broader_predicate
        full_results[:narrower_predicate] = override_results[:narrower_predicate] if override_results.key? :narrower_predicate
        full_results[:sameas_predicate] = override_results[:sameas_predicate] if override_results.key? :sameas_predicate
        full_results[:sort_predicate] = override_results[:sort_predicate] if override_results.key? :sort_predicate
      end

      def merge_subauths(full_subauths, override_subauths)
        full_subauths.merge! override_subauths
      end
    end
  end
end
