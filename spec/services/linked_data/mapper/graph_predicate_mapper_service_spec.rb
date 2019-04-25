require 'spec_helper'

RSpec.describe Qa::LinkedData::Mapper::GraphPredicateMapperService do
  let(:graph) { Qa::LinkedData::GraphService.load_graph(url: 'http://local.data') }
  let(:predicate_map) do
    {
      uri: :subject_uri,
      id: RDF::URI.new('http://purl.org/dc/terms/identifier'),
      label: RDF::URI.new('http://www.w3.org/2004/02/skos/core#prefLabel'),
      altlabel: RDF::URI.new('http://www.w3.org/2004/02/skos/core#altLabel'),
      sameas: RDF::URI.new('http://www.w3.org/2004/02/skos/core#sameAs'),
      sort: RDF::URI.new('http://vivoweb.org/ontology/core#rank')
    }
  end

  before do
    stub_request(:get, 'http://local.data')
      .to_return(status: 200, body: webmock_fixture('lod_3_ranked_varying_preds.nt'), headers: { 'Content-Type' => 'application/n-triples' })
  end

  describe '.map_values' do
    subject { described_class.map_values(graph: graph, predicate_map: predicate_map, subject_uri: subject_uri) }

    context 'when each predicate has one value' do
      let(:subject_uri) { RDF::URI.new('http://id.worldcat.org/fast/530369') }

      it 'maps graph values to predicates' do
        expect(subject.count).to eq 6
        expect(subject).to be_kind_of Hash
        expect(subject.keys).to match_array [:uri, :id, :label, :altlabel, :sameas, :sort]

        validate_entry(subject, :uri, [subject_uri.to_s], RDF::URI)
        validate_entry(subject, :id, ['530369'], RDF::Literal)
        validate_entry(subject, :label, ['Cornell University'], RDF::Literal)
        validate_entry(subject, :altlabel, ['Ithaca (N.Y.). Cornell University'], RDF::Literal)
        validate_entry(subject, :sameas, ['http://id.loc.gov/authorities/names/n79021621'], RDF::URI)
        validate_entry(subject, :sort, ['1'], RDF::Literal)
      end
    end

    context 'when some predicates have multiple values' do
      let(:subject_uri) { RDF::URI.new('http://id.worldcat.org/fast/510103') }

      it 'maps graph values to predicates' do
        expect(subject.count).to eq 6
        expect(subject).to be_kind_of Hash
        expect(subject.keys).to match_array [:uri, :id, :label, :altlabel, :sameas, :sort]

        validate_entry(subject, :uri, [subject_uri.to_s], RDF::URI)
        validate_entry(subject, :id, ['510103'], RDF::Literal)
        validate_entry(subject, :label, ['Cornell University. Libraries'], RDF::Literal)
        validate_entry(subject, :altlabel, ['Cornell University. Central Libraries', 'Cornell University. John M. Olin Library', 'Cornell University. White Library'], RDF::Literal)
        validate_entry(subject, :sameas, ['http://id.loc.gov/authorities/names/n50000040', 'https://viaf.org/viaf/147713418'], RDF::URI)
        validate_entry(subject, :sort, ['2'], RDF::Literal)
      end
    end

    context 'when some predicates has no values' do
      let(:subject_uri) { RDF::URI.new('http://id.worldcat.org/fast/5140') }

      it 'maps graph values to predicates' do
        expect(subject.count).to eq 6
        expect(subject).to be_kind_of Hash
        expect(subject.keys).to match_array [:uri, :id, :label, :altlabel, :sameas, :sort]

        validate_entry(subject, :uri, [subject_uri.to_s], RDF::URI)
        validate_entry(subject, :id, ['5140'], RDF::Literal)
        validate_entry(subject, :label, ['Cornell, Joseph'], RDF::Literal)
        validate_entry(subject, :altlabel, [], NilClass)
        validate_entry(subject, :sameas, [], NilClass)
        validate_entry(subject, :sort, ['3'], RDF::Literal)
      end
    end

    context 'when block is passed in' do
      let(:subject_uri) { RDF::URI.new('http://id.worldcat.org/fast/5140') }
      let(:context) do
        { location: '42.4488° N, 76.4763° W' }
      end
      let(:subject) do
        described_class.map_values(graph: graph, predicate_map: predicate_map, subject_uri: subject_uri) do |value_map|
          value_map[:context] = context
          value_map
        end
      end

      it 'yields to passed in block' do
        expect(subject.count).to eq 7
        expect(subject).to be_kind_of Hash
        expect(subject.keys).to match_array [:uri, :id, :label, :altlabel, :sameas, :sort, :context]

        validate_entry(subject, :uri, [subject_uri.to_s], RDF::URI)
        validate_entry(subject, :id, ['5140'], RDF::Literal)
        validate_entry(subject, :label, ['Cornell, Joseph'], RDF::Literal)
        validate_entry(subject, :altlabel, [], NilClass)
        validate_entry(subject, :sameas, [], NilClass)
        validate_entry(subject, :sort, ['3'], RDF::Literal)

        expect(subject[:context]).to be_kind_of Hash
        expect(subject[:context]).to include(context)
      end
    end
  end

  def validate_entry(results, key, values, entry_kind)
    expect(results[key]).to be_kind_of Array
    expect(results[key].first).to be_kind_of entry_kind
    expect(results[key].map(&:to_s)).to match_array values
  end
end
