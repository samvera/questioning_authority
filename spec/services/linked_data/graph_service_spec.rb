# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Qa::LinkedData::GraphService do
  describe '.load_graph' do
    subject { described_class.load_graph(url: url) }
    let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }

    context 'when graph can be loaded' do
      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 200, body: webmock_fixture('lod_oclc_all_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
      end

      it 'builds a graph with many statements' do
        expect(subject).to be_kind_of RDF::Graph
        expect(subject.statements.size).to be > 10
      end
    end

    context 'when term is not found' do
      let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }

      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 404)
      end

      it 'raises error' do
        expect { described_class.load_graph(url: url) }.to raise_error(Qa::TermNotFound, "#{url} Not Found - Term may not exist at LOD Authority. (HTTPNotFound - 404)")
      end
    end

    context 'when service error' do
      subject { described_class.load_graph(url: url) }

      let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
      let(:uri) { URI(url) }

      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 500)
      end

      it 'raises error' do
        expect { subject }.to raise_error(Qa::ServiceError, "#{uri.hostname} on port #{uri.port} is not responding.  Try again later. (HTTPServerError - 500)")
      end
    end

    context 'when service unavailable' do
      subject { described_class.load_graph(url: url) }

      let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
      let(:uri) { URI(url) }

      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 503)
      end

      it 'raises error' do
        expect { subject }.to raise_error(Qa::ServiceUnavailable, "#{uri.hostname} on port #{uri.port} is not responding.  Try again later. (HTTPServiceUnavailable - 503)")
      end
    end

    context "when error isn't specifically handled" do
      subject { described_class.load_graph(url: url) }

      let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
      let(:regurl) { 'http:\/\/experimental.worldcat.org\/fast\/search\?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
      let(:uri) { URI(url) }

      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 504)
      end

      it 'raises error' do
        expect { subject }.to raise_error(Qa::ServiceError, /Unknown error for #{uri.hostname} on port #{uri.port}.  Try again later. \(Cause - <#{regurl}>: \(?504\)?\)/)
      end
    end
  end

  describe '.filter' do
    context 'with language filter' do
      subject { described_class.filter(graph: graph, language: language) }

      let(:url) { 'http://authority.with.language/search?query=foo' }
      let(:graph) { described_class.load_graph(url: url) }

      let(:en_dried_milk) { RDF::Literal.new("dried milk", language: :en) }
      let(:fr_dried_milk) { RDF::Literal.new("lait en poudre", language: :fr) }
      let(:de_dried_milk) { RDF::Literal.new("getrocknete Milch", language: :de) }

      let(:en_buttermilk) { RDF::Literal.new("buttermilk", language: :en) }
      let(:fr_buttermilk) { RDF::Literal.new("Babeurre", language: :fr) }
      let(:de_buttermilk) { RDF::Literal.new("Buttermilch", language: :de) }

      let(:en_condensed_milk) { RDF::Literal.new("condensed milk", language: :en) }
      let(:fr_condensed_milk) { RDF::Literal.new("lait condensé", language: :fr) }
      let(:de_condensed_milk) { RDF::Literal.new("Kondensmilch", language: :de) }

      before do
        stub_request(:get, 'http://authority.with.language/search?query=foo')
          .to_return(status: 200, body: webmock_fixture('lod_lang_search_enfrde.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
      end

      context 'when one language passed in' do
        let(:language) { [:fr] }

        it 'returns the graph with only the French subset of triples' do
          expect(subject.has_object?(en_dried_milk)).to be false
          expect(subject.has_object?(en_buttermilk)).to be false
          expect(subject.has_object?(en_condensed_milk)).to be false

          expect(subject.has_object?(fr_dried_milk)).to be true
          expect(subject.has_object?(fr_buttermilk)).to be true
          expect(subject.has_object?(fr_condensed_milk)).to be true

          expect(subject.has_object?(de_dried_milk)).to be false
          expect(subject.has_object?(de_buttermilk)).to be false
          expect(subject.has_object?(de_condensed_milk)).to be false
        end
      end

      context "when mix of language markers on graph statements" do
        let(:nomarker_de_buttermilk) { RDF::Literal.new("Buttermilch") }
        let(:language) { [:fr] }

        before do
          stub_request(:get, 'http://authority.with.language/search?query=foo')
            .to_return(status: 200, body: webmock_fixture('lod_lang_search_filtering.nt'), headers: { 'Content-Type' => 'application/n-triples' })
        end

        it 'filters down to the expected size' do
          expect(graph.size).to eq 11
          expect(subject.size).to eq 8
        end

        it 'the graph includes triples where object has the targeted language marker (e.g. :fr)' do
          expect(subject.has_object?(fr_dried_milk)).to be true
          expect(subject.has_object?(fr_buttermilk)).to be true
        end

        it 'the graph includes triples where object does not have a language marker' do
          expect(subject.has_object?(nomarker_de_buttermilk)).to be true
        end

        it "the graph includes triples regardless of language when there are no object's for the predicate that have the targeted language marker" do
          expect(subject.has_object?(en_condensed_milk)).to be true
          expect(subject.has_object?(de_condensed_milk)).to be true
        end

        it 'filters out the rest' do
          expect(subject.has_object?(en_dried_milk)).to be false
          expect(subject.has_object?(en_buttermilk)).to be false
          expect(subject.has_object?(de_dried_milk)).to be false
        end
      end

      context 'when multiple languages passed in' do
        let(:language) { [:en, :fr] }

        it 'returns the graph with English and French subset of triples' do
          expect(subject.has_object?(en_dried_milk)).to be true
          expect(subject.has_object?(en_buttermilk)).to be true
          expect(subject.has_object?(en_condensed_milk)).to be true

          expect(subject.has_object?(fr_dried_milk)).to be true
          expect(subject.has_object?(fr_buttermilk)).to be true
          expect(subject.has_object?(fr_condensed_milk)).to be true

          expect(subject.has_object?(de_dried_milk)).to be false
          expect(subject.has_object?(de_buttermilk)).to be false
          expect(subject.has_object?(de_condensed_milk)).to be false
        end
      end
    end

    context 'with filter out subject blanknodes' do
      subject { described_class.filter(graph: graph, remove_blanknode_subjects: true) }

      let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
      let(:graph) { described_class.load_graph(url: url) }

      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 200, body: webmock_fixture('lod_search_with_blanknode_subjects.nt'), headers: { 'Content-Type' => 'application/n-triples' })
      end

      it 'removes statements where the subject is a blanknode' do
        expect(graph.size).to be 18
        expect(subject.size).to be 12
      end
    end
  end

  describe '.object_values' do
    subject { described_class.object_values(graph: graph, subject: subject_uri, predicate: predicate_uri) }

    let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
    let(:graph) { described_class.load_graph(url: url) }
    let(:subject_uri) { RDF::URI('http://id.worldcat.org/fast/530369') }
    let(:predicate_uri) { RDF::URI('http://schema.org/sameAs') }

    before do
      stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
        .to_return(status: 200, body: webmock_fixture('lod_oclc_all_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
    end

    it 'returns all values for the subject-predicate pair' do
      expect(subject.size).to be 2
      expect(subject.map(&:to_s)).to match_array ['http://id.loc.gov/authorities/names/n79021621', 'https://viaf.org/viaf/126293486']
    end
  end

  describe '.deep_copy' do
    subject { described_class.object_values(graph: graph, subject: subject_uri, predicate: predicate_uri) }

    let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
    let(:graph) { described_class.load_graph(url: url) }
    let(:copied_graph) { described_class.deep_copy(graph: graph) }

    before do
      stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
        .to_return(status: 200, body: webmock_fixture('lod_oclc_all_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
    end

    it 'returns a copy of the graph' do
      expect(copied_graph).to be_kind_of RDF::Graph
      expect(copied_graph.statements.count).to eq graph.statements.count
    end
  end
end
