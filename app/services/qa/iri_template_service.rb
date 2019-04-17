# Provide service for building a URL based on an IRI Templated Link and its variable mappings based on provided substitutions.
module Qa
  class IriTemplateService
    class << self
      # Construct an url from an IriTemplate making identified substitutions
      # @param url_config [Qa::IriTemplate::UrlConfig] configuration (json) holding the template and variable mappings
      # @param substitutions [HashWithIndifferentAccess] name-value pairs to substitute into the url template
      # @return [String] url with substitutions
      def build_url(url_config:, substitutions:)
        # TODO: This is a very simple approach using direct substitution into the template string.
        #   Better would be to...
        #     * appropriately adds '?' or '&'
        #     * ensure proper escaping of values (e.g. value="A simple string" which is encoded as A%20simple%20string)
        #   Even more advanced would be to...
        #     * support BasicRepresentation (which is what it does now)
        #     * support ExplicitRepresentation
        #        * literal encoding for values (e.g. value="A simple string" becomes %22A%20simple%20string%22)
        #        * language encoding for values (e.g. value="A simple string" becomes value="A simple string"@en which is encoded as %22A%20simple%20string%22%40en)
        #        * type encoding for values (e.g. value=5.5 becomes value="5.5"^^http://www.w3.org/2001/XMLSchema#decimal which is encoded
        #                                         as %225.5%22%5E%5Ehttp%3A%2F%2Fwww.w3.org%2F2001%2FXMLSchema%23decimal)
        # Fuller implementations parse the template into component parts and then build the URL by adding parts in as applicable.
        url = url_config.template
        url_config.mapping.each do |m|
          key = m.variable
          url = url.gsub("{#{key}}", m.simple_value(substitutions[key]))
          url = url.gsub("{?#{key}}", m.parameter_value(substitutions[key]))
        end
        clean(url)
      end

      private

        # In the process of substitution, if a value is missing, you can end up with '?&', '&&', or ending with '&'.  These are all removed this method.
        def clean(url)
          url.gsub(/&&*/, '&').chomp('&').gsub('?&', '?')
        end
    end
  end
end
