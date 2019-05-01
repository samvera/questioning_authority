# Service to sort an array of literals by language and within language.
module Qa
  module LinkedData
    class LanguageSortService
      LANGUAGE_LOCALE_KEY_FOR_NO_LANGUAGE = :NO_LANGUAGE

      attr_reader :literals, :preferred_language
      attr_reader :languages, :bins
      private :literals, :preferred_language, :languages, :bins

      # @param [Array<RDF::Literals>] string literals to sort
      # @param [Symbol] preferred language to appear first in the list; defaults to no preference
      # @return instance of this class
      def initialize(literals, preferred_language = nil)
        @literals = literals
        @preferred_language = preferred_language
        @languages = []
        @bins = {}
      end

      # Sort the literals stored in this instance of the service
      # @return [Array<RDF::Literals] sorted version of literals
      def sort
        return literals unless literals.present?
        return @sorted_literals if @sorted_literals.present?
        parse_into_language_bins
        sort_languages
        sort_language_bins
        @sorted_literals = construct_sorted_literals
      end

      # Sort the literals and return as an array of strings with only unique literals and empty strings removed
      # @return [Array<String>] sorted version of literals as strings
      def uniq_sorted_strings
        sort.map(&:to_s).uniq.delete_if(&:blank?)
      end

      private

        def construct_sorted_literals
          sorted_literals = []
          0.upto(languages.size - 1) { |idx| sorted_literals.concat(bins[languages[idx]]) }
          sorted_literals
        end

        def language(literal)
          return LANGUAGE_LOCALE_KEY_FOR_NO_LANGUAGE unless Qa::LinkedData::LanguageService.literal_has_language_marker? literal
          literal.language
        end

        def move_no_language_to_end
          return unless languages.include?(LANGUAGE_LOCALE_KEY_FOR_NO_LANGUAGE)
          languages.delete(LANGUAGE_LOCALE_KEY_FOR_NO_LANGUAGE)
          languages << LANGUAGE_LOCALE_KEY_FOR_NO_LANGUAGE
        end

        def move_preferred_language_to_front
          return unless preferred_language.present? && languages.include?(preferred_language)
          languages.delete(preferred_language)
          languages.insert(0, preferred_language)
        end

        def parse_into_language_bins
          0.upto(literals.size - 1) do |idx|
            lang = language(literals[idx])
            languages << lang
            bin = bins.fetch(lang, [])
            bin << literals[idx]
            bins[lang] = bin
          end
          @language = languages
          @bins = bins
        end

        def sort_languages
          languages.sort!.uniq!
          move_preferred_language_to_front
          move_no_language_to_end
        end

        def sort_language_bins
          bins.each_value { |bin| bin.sort_by! { |literal| literal.to_s.downcase } }
        end
    end
  end
end
