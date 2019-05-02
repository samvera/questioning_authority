require 'spec_helper'

RSpec.describe Qa::LinkedData::Mapper::TermResultsMapperService do
  let(:graph) { Qa::LinkedData::GraphService.load_graph(url: 'http://local.data') }
  let(:subjects) { subject.map { |result| result[:uri].first.to_s } }

  let(:expected) do
    {
      uri: ['http://aims.fao.org/aos/agrovoc/c_9513'],
      id: ['http://aims.fao.org/aos/agrovoc/c_9513'],
      label: ['buttermilk'],
      altlabel: ['yummy'],
      broader: ['http://aims.fao.org/aos/agrovoc/c_4830'],
      narrower: [],
      sameas: ['http://cat.aii.caas.cn/concept/c_26308',
               'http://lod.nal.usda.gov/nalt/20627',
               'http://d-nb.info/gnd/4147072-2']
    }
  end

  let(:results) do
    results = {}
    subject.each { |k, v| results[k] = v.map(&:to_s) }
    results
  end

  before do
    stub_request(:get, 'http://local.data')
      .to_return(status: 200, body: webmock_fixture('lod_lang_term_en.rdf.xml'), headers: { 'Content-Type' => 'application/application/rdf+xml' })
  end

  describe '.map_values' do
    context 'when given a predicate map' do
      subject { described_class.map_values(graph: graph, predicate_map: predicate_map, subject_uri: RDF::URI.new('http://aims.fao.org/aos/agrovoc/c_9513')) }

      let(:predicate_map) do
        {
          uri: :subject_uri,
          id: :subject_uri,
          label: RDF::URI.new('http://www.w3.org/2004/02/skos/core#prefLabel'),
          altlabel: RDF::URI.new('http://www.w3.org/2004/02/skos/core#altLabel'),
          narrower: RDF::URI.new('http://www.w3.org/2004/02/skos/core#narrower'),
          broader: RDF::URI.new('http://www.w3.org/2004/02/skos/core#broader'),
          sameas: RDF::URI.new('http://www.w3.org/2004/02/skos/core#exactMatch')
        }
      end

      it 'maps all values with a subject uri' do
        expect(subject).to be_kind_of Hash
        expect(results[:uri]).to match_array expected[:uri]
        expect(results[:id]).to match_array expected[:id]
        expect(results[:label]).to match_array expected[:label]
        expect(results[:altlabel]).to match_array expected[:altlabel]
        expect(results[:broader]).to match_array expected[:broader]
        expect(results[:narrower]).to match_array expected[:narrower]
        expect(results[:sameas]).to match_array expected[:sameas]
      end
    end

    context 'when given an ldpath map' do
      subject { described_class.map_values(graph: graph, prefixes: prefixes, ldpath_map: ldpath_map, subject_uri: RDF::URI.new('http://aims.fao.org/aos/agrovoc/c_9513')) }

      let(:prefixes) do
        {
          dcterms: 'http://purl.org/dc/terms/',
          skos: 'http://www.w3.org/2004/02/skos/core#'
        }
      end

      let(:ldpath_map) do
        {
          uri: :subject_uri,
          id: :subject_uri,
          label: 'skos:prefLabel :: xsd:string',
          altlabel: 'skos:altLabel :: xsd:string',
          narrower: 'skos:narrower :: xsd:anyURI',
          broader: 'skos:broader :: xsd:anyURI',
          sameas: 'skos:exactMatch :: xsd:anyURI'
        }
      end

      it 'maps all values with a subject uri' do
        expect(subject).to be_kind_of Hash
        expect(results[:uri]).to match_array expected[:uri]
        expect(results[:id]).to match_array expected[:id]
        expect(results[:label]).to match_array expected[:label]
        expect(results[:altlabel]).to match_array expected[:altlabel]
        expect(results[:broader]).to match_array expected[:broader]
        expect(results[:narrower]).to match_array expected[:narrower]
        expect(results[:sameas]).to match_array expected[:sameas]
      end
    end
  end
end
