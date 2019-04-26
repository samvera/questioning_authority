# Service to determine which language to use for sorting and filtering.
module Qa
  module LinkedData
    class LanguageService
      WILDCARD = '*'.freeze

      class << self
        # @param user_langauge [Symbol|String] the language code (e.g. :en, :fr) specified as URL parameter or on URL header
        # @param authority_language [Symbol|String|Array<Symbol|String>] the default language specified in the authority's configuration file
        # @return [Array<Symbol>] the selected language(s) normalized as an array of symbols (e.g. [:en, :fr])
        # @note Precedence from high to low:
        #       * user_language (with URL parameter preferred over URL header)
        #       * authority_language (defined in authority config)
        #       * site default_language (defined in QA initializer)
        def preferred_language(user_language: nil, authority_language: nil)
          return normalize_language(user_language) if user_language.present?
          return normalize_language(authority_language) if authority_language.present?
          normalize_language(Qa.config.default_language)
        end

        # @param [RDF::Literal] the literal to check
        # @return [Boolean] true if literal has a language tag; otherwise, false
        def literal_has_language_marker?(literal)
          return false unless literal.respond_to?(:language)
          literal.language.present?
        end

        private

          # Normalize language
          # @param [String | Symbol | Array] language for filtering graph (e.g. "en" OR :en OR ["en", "fr"] OR [:en, :fr])
          # @return [Array<Symbol>] an array of languages encoded as symbols (e.g. [:en] OR [:en, :fr])
          def normalize_language(language)
            return language if language.blank?
            language = [language] unless language.is_a? Array
            return nil if language.include?(WILDCARD)
            language.map(&:to_sym)
          end
      end
    end
  end
end
