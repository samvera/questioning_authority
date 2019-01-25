require 'spec_helper'

RSpec.describe Qa::LinkedData::Mapper::SearchResultsMapperService do
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
  let(:subjects) { subject.map { |result| result[:uri].first.to_s } }

  before do
    stub_request(:get, 'http://local.data')
      .to_return(status: 200, body: webmock_fixture('lod_2_ranked_2_unranked.nt'), headers: { 'Content-Type' => 'application/n-triples' })
  end

  describe '.map_values' do
    subject { described_class.map_values(graph: graph, predicate_map: predicate_map, sort_key: sort_key) }

    let(:sort_key) { :sort }
    let(:expected530369) do
      {
        uri: [RDF::URI.new('http://id.worldcat.org/fast/530369')],
        id: [RDF::Literal.new('530369')],
        label: [RDF::Literal.new('Cornell University')],
        altlabel: [RDF::Literal.new('Ithaca (N.Y.). Cornell University')],
        sameas: [RDF::URI.new('http://id.loc.gov/authorities/names/n79021621')],
        sort: [RDF::Literal.new('1')]
      }
    end
    let(:expected5140) do
      {
        uri: [RDF::URI.new('http://id.worldcat.org/fast/5140')],
        id: [RDF::Literal.new('5140')],
        label: [RDF::Literal.new('Cornell, Joseph')],
        altlabel: [RDF::URI.new('_:b0')],
        sameas: [],
        sort: [RDF::Literal.new('3')]
      }
    end

    it 'maps all subjects with a sort predicate' do
      expect(subject.count).to eq 2
      expect(subject).to be_kind_of Array
      expect(subjects).to eq ["http://id.worldcat.org/fast/530369", "http://id.worldcat.org/fast/5140"]

      actual530369 = subject.first
      actual5140 = subject.second
      expect(actual530369).to eq expected530369
      expect(actual5140).to eq expected5140
    end

    it 'does not include subjects missing sort predicate' do
      expect(subjects).not_to include "http://id.worldcat.org/fast/510103"
      expect(subjects).not_to include "_:b0"
    end

    context 'when context_map is passed in' do
      subject { described_class.map_values(graph: graph, predicate_map: predicate_map, sort_key: sort_key, context_map: context_map) }

      let(:context_map) { instance_double(Qa::LinkedData::Config::ContextMap) }
      let(:context) do
        { location: '42.4488° N, 76.4763° W' }
      end
      let(:expected530369_with_context) do
        {
          uri: [RDF::URI.new('http://id.worldcat.org/fast/530369')],
          id: [RDF::Literal.new('530369')],
          label: [RDF::Literal.new('Cornell University')],
          altlabel: [RDF::Literal.new('Ithaca (N.Y.). Cornell University')],
          sameas: [RDF::URI.new('http://id.loc.gov/authorities/names/n79021621')],
          sort: [RDF::Literal.new('1')],
          context: context
        }
      end
      let(:expected5140_with_context) do
        {
          uri: [RDF::URI.new('http://id.worldcat.org/fast/5140')],
          id: [RDF::Literal.new('5140')],
          label: [RDF::Literal.new('Cornell, Joseph')],
          altlabel: [RDF::URI.new('_:b0')],
          sameas: [],
          sort: [RDF::Literal.new('3')],
          context: context
        }
      end

      before do
        allow(Qa::LinkedData::Mapper::ContextMapperService).to receive(:map_context).with(graph: anything, context_map: anything, subject_uri: anything).and_return(context)
      end

      it 'adds context if requested' do
        expect(subject.count).to eq 2
        expect(subject).to be_kind_of Array
        expect(subjects).to eq ["http://id.worldcat.org/fast/530369", "http://id.worldcat.org/fast/5140"]

        actual530369 = subject.first
        actual5140 = subject.second
        expect(actual530369).to eq expected530369_with_context
        expect(actual5140).to eq expected5140_with_context
      end
    end
  end
end
