# frozen_string_literal: true
require 'spec_helper'

describe Qa::Services::RDFAuthorityParser do
  let(:source) { [File.join(fixture_path, 'lexvo_snippet.rdf')] }
  let(:format) { 'rdfxml' }
  let(:predicate) { RDF::URI("http://www.w3.org/2008/05/skos#prefLabel") }
  let(:name) { 'language' }
  let(:alum_entry) { Qa::LocalAuthorityEntry.find_by(label: 'Alumu-Tesu') }
  let(:ari_entry) { Qa::LocalAuthorityEntry.find_by(label: 'Ari') }

  describe "#import_rdf" do
    before { described_class.import_rdf(name, source, format: format, predicate: predicate) }
    it "creates the authority and authority entries" do
      expect(Qa::LocalAuthority.count).to eq(1)
      expect(Qa::LocalAuthority.find_by(name: name)).not_to be_nil
      expect(Qa::LocalAuthorityEntry.count).to eq(2)
      expect(alum_entry.uri).to eq('http://lexvo.org/id/iso639-3/aab')
      expect(ari_entry.uri).to eq('http://lexvo.org/id/iso639-3/aac')
    end
  end
end
