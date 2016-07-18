# frozen_string_literal: true
module Qa
  module Services
    # Class to parse downloaded content from rdf sources such as
    # Library of Congress and Lexvo to create LocalAuthorityEntries
    # for a named LocalAuthority.
    #
    # Example calls:
    # RDFAuthorityParser.import_rdf('subjects',['/tmp/authoritiessubjects.nt'])
    # RDFAuthorityParser.import_rdf('languages',['/tmp/lexvo_2013-02-09.rdf'],
    #        format: 'rdfxml',
    #        predicate: RDF::URI("http://www.w3.org/2008/05/skos#prefLabel"))
    #
    class RDFAuthorityParser
      class << self
        # import the rdf from the sources and store them as entries for the
        # named LocalAuthority
        #
        # @param [String] name    The name of the authority to update
        # @param [Array]  sources An array of file names to process
        # @param [Hash]   opts    options for processing
        # @option [opts]  :format     format of the rdf to parse
        #                              see RDF::Reader for valid options
        #                             defaults to :ntripples
        # @option [opts]  :predicate  label predicate to use for
        #                              LocalAuthorityEntry.label, which
        #                              must match a field in the source file(s)
        #                             defaults to http://www.w3.org/2004/02/skos/core#prefLabel
        def import_rdf(name, sources, opts = {})
          authority = Qa::LocalAuthority.find_or_create_by(name: name)
          format = opts.fetch(:format, :ntriples)
          predicate = opts.fetch(:predicate, ::RDF::Vocab::SKOS.prefLabel)
          sources.each do |uri|
            import_source(authority, format, predicate, uri)
          end
        end

        private

        def import_source(authority, format, predicate, uri)
          ::RDF::Reader.open(uri, format: format) do |reader|
            reader.each_statement do |statement|
              parse_statement(statement, predicate, authority)
            end
          end
        end

        def parse_statement(statement, predicate, authority)
          return unless statement.predicate == predicate
          Qa::LocalAuthorityEntry.create(local_authority: authority,
                                         label: statement.object.to_s,
                                         uri: statement.subject.to_s)
        rescue ActiveRecord::RecordNotUnique
          Rails.logger.warn("Duplicate record: #{statement.subject}")
        end
      end
    end
  end
end
