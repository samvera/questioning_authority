# Provide service for for sorting an array of hash based on the values at a specified key in the hash.
module Qa
  module LinkedData
    class DeepSortService
      # @param [Array<Hash<Symbol,Array<RDF::Literal>>>] the array of hashes to sort
      # @param [sort_key] the key in the hash on whose value the array will be sorted
      # @param [Symbol] preferred language to appear first in the list; defaults to no preference
      # @return instance of this class
      # @example the_array parameter
      #   [
      #     {:uri=>[#<RDF::URI:0x3fcff54a829c URI:http://id.loc.gov/authorities/names/n2010043281>],
      #      :id=>[#<RDF::Literal:0x3fcff4a367b4("n 2010043281")>],
      #      :label=>[#<RDF::Literal:0x3fcff54a9a98("Valli, Sabrina"@en)>],
      #      :altlabel=>[],
      #      :sort=>[#<RDF::Literal:0x3fcff54b4c18("2")>]},
      #     {:uri=>[#<RDF::URI:0x3fcff54a829c URI:http://id.loc.gov/authorities/names/n201002344>],
      #      :id=>[#<RDF::Literal:0x3fcff4a367b4("n 201002344")>],
      #      :label=>[#<RDF::Literal:0x3fcff54a9a98("Cornell, Joseph"@en)>],
      #      :altlabel=>[],
      #      :sort=>[#<RDF::Literal:0x3fcff54b4c18("1")>]}
      #   ]
      def initialize(the_array, sort_key, preferred_language = nil)
        @sortable_elements = the_array.map { |element| DeepSortElement.new(element, sort_key, preferred_language) }
      end

      # Sort an array of hash on the specified sort key.  The value in the hash at sort key is expected to be an array
      # with one or more values that are RDF::Literals that translate to a number (e.g. 2), a string number (e.g. "3"),
      # a string (e.g. "hello"), or a language qualified string (e.g. "hello"@en).
      # The sort occurs in the following precedence.
      # * preference for numeric sort (if only one value each and both are integers or a string that can be converted to an integer)
      # * single value sort (if only one value each and at least one is not an integer)
      # * multiple values sort (if either has multiple values)
      # @return the sorted array
      # @example returned sorted array
      #   [
      #     {:uri=>[#<RDF::URI:0x3fcff54a829c URI:http://id.loc.gov/authorities/names/n201002344>],
      #      :id=>[#<RDF::Literal:0x3fcff4a367b4("n 201002344")>],
      #      :label=>[#<RDF::Literal:0x3fcff54a9a98("Cornell, Joseph"@en)>],
      #      :altlabel=>[],
      #      :sort=>[#<RDF::Literal:0x3fcff54b4c18("1")>]},
      #     {:uri=>[#<RDF::URI:0x3fcff54a829c URI:http://id.loc.gov/authorities/names/n2010043281>],
      #      :id=>[#<RDF::Literal:0x3fcff4a367b4("n 2010043281")>],
      #      :label=>[#<RDF::Literal:0x3fcff54a9a98("Valli, Sabrina"@en)>],
      #      :altlabel=>[],
      #      :sort=>[#<RDF::Literal:0x3fcff54b4c18("2")>]}
      #   ]
      def sort
        @sortable_elements.sort.map(&:element)
      end

      class DeepSortElement
        attr_reader :element, :literals, :preferred_language
        private :preferred_language

        delegate :size, to: :@literals

        def initialize(element, sort_key, preferred_language)
          element[sort_key] = Qa::LinkedData::LanguageSortService.new(element[sort_key], preferred_language).sort
          @element = element
          @literals = element[sort_key]
          @preferred_language = preferred_language
          @includes_preferred_language = includes_preferred_language?
          @all_same_language = all_same_language?
        end

        def <=>(other)
          return numeric_comparator(other) if integer? && other.integer?
          return single_value_comparator(other) if single? && other.single?
          multiple_value_comparator(other)
        end

        # @return true if there is a single literal that is an integer or a string that can be converted to an integer; otherwise, false
        def integer?
          return false unless single?
          (/\A[-+]?\d+\z/ === literal.to_s) # rubocop:disable Style/CaseEquality
        end

        def integer(idx = 0)
          Integer(literal(idx).to_s)
        end

        # @return true if there is only one value; otherwise, false
        def single?
          @single ||= literals.size == 1
        end

        def literal(idx = 0)
          literals[idx]
        end

        def downcase_string(idx = 0)
          to_downcase(literal(idx))
        end

        def language(lit = literals.first)
          return nil unless Qa::LinkedData::LanguageService.literal_has_language_marker? lit
          lit.language
        end

        def includes_preferred_language?
          return @includes_preferred_language if @includes_preferred_language.present?
          # literals are sorted by language with preferred language first in the list
          @includes_preferred_language = (language == preferred_language)
        end

        def all_same_language?
          return @all_same_language if @all_same_language.present?
          # literals are sorted by language, so if first = last, then all are the same
          @all_same_language = (language(literals.first) == language(literals.last))
        end

        def languages
          filtered_literals_by_language.keys
        end

        def filtered_literals(filter_language)
          filtered_literals_by_language.fetch(filter_language, [])
        end

        private

          # If both test values are single value and both are integers, do a numeric sort
          def numeric_comparator(other)
            integer <=> other.integer
          end

          # If both test values are single value and at least one is not numeric, do a string sort taking language into consideration
          # * sort values if neither has a language marker or they both have the same language marker
          # * otherwise, sort language markers
          def single_value_comparator(other)
            return downcase_string <=> other.downcase_string if same_language?(literal, other.literal)
            compare_languages(language, other.language)
          end

          def compare_languages(lang, other_lang)
            return -1 if preferred_language? lang
            return 1 if preferred_language? other_lang
            return -1 if other_lang.blank?
            return 1 if lang.blank?
            lang <=> other_lang
          end

          # If at least one of the test values has multiple values, sort the multiple values taking language into consideration
          # * if both lists have all the same language or no language markers at all, just sort the lists and compare each element
          # * if either list has the preferred language, try to sort the two lists by element after filtering for the preferred language
          # * otherwise, sort by language until there is a difference
          def multiple_value_comparator(other)
            return single_language_list_comparator(other) if all_same_language? && other.all_same_language?
            return specified_language_list_comparator(other, preferred_language) if includes_preferred_language? && other.includes_preferred_language?
            multi_language_list_comparator(other)
          end

          def single_language_list_comparator(other)
            list_comparator(literals, other.literals)
          end

          def specified_language_list_comparator(other, lang)
            filtered = filtered_literals(lang)
            other_filtered = other.filtered_literals(lang)
            return -1 if !filtered.empty? && other_filtered.empty?
            return 1 if filtered.empty? && !other_filtered.empty?
            list_comparator(filtered, other_filtered)
          end

          # Walk through language sorted lists
          # * for each language, determine how closely the list of terms matches
          # * prioritize the list that gets the most low values
          def multi_language_list_comparator(other)
            combined_languages = languages.concat(other.languages).uniq
            by_language_comparisons = {}
            combined_languages.each do |lang|
              cmp = list_comparator(filtered_literals(lang), other.filtered_literals(lang))
              by_language_comparisons[lang] = cmp
            end
            cmp_sum = by_language_comparisons.values.sum
            return 1 if cmp_sum.positive?
            return -1 if cmp_sum.negative?
            0
          end

          def list_comparator(list, other_list)
            # if an element doesn't have any terms in a language, the other element sorts lower
            return -1 if other_list.empty?
            return 1 if list.empty?
            shorter_list_size = [list.size, other_list.size].min
            cmp = 0
            0.upto(shorter_list_size - 1) do |idx|
              cmp = to_downcase(list[idx]) <=> to_downcase(other_list[idx])
              return cmp unless cmp.zero?
            end
            return cmp if list.size == other_list.size
            other_list.size < list.size ? 1 : -1 # didn't find any diffs, shorter list is considered lower
          end

          def same_language?(lit, other_lit)
            return false if only_one_has_language_marker?(lit, other_lit)
            return true if neither_have_language_markers?(lit, other_lit)
            lit.language == other_lit.language
          end

          def neither_have_language_markers?(lit, other_lit)
            !language?(lit) && !language?(other_lit)
          end

          def only_one_has_language_marker?(lit, other_lit)
            (!language?(lit) && language?(other_lit)) || (language?(lit) && !language?(other_lit))
          end

          def language?(lit)
            Qa::LinkedData::LanguageService.literal_has_language_marker? lit
          end

          def preferred_language?(lang)
            preferred_language.present? ? lang == preferred_language : false
          end

          def to_downcase(lit)
            lit.to_s.downcase
          end

          def filtered_literals_by_language
            @filtered_literals_by_language ||= create_all_filters
          end

          def create_all_filters
            bins = {}
            0.upto(size - 1) do |idx|
              lang = language(literals[idx])
              filter = bins.fetch(lang, [])
              filter << literal(idx)
              bins[lang] = filter
            end
            bins
          end
      end
      private_constant :DeepSortElement
    end
  end
end
