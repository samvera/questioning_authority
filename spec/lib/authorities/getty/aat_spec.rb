# frozen_string_literal: true
require 'spec_helper'

describe Qa::Authorities::Getty::AAT do
  let(:authority) { described_class.new }

  describe "#build_query_url" do
    subject { authority.build_query_url("foo") }
    it { is_expected.to match(/^http:\/\/vocab\.getty\.edu\//) }
  end

  describe "#find_url" do
    subject { authority.find_url("300053264") }
    it { is_expected.to eq "http://vocab.getty.edu/download/json?uri=http://vocab.getty.edu/aat/300053264.json" }
  end

  describe "#search" do
    context "authorities" do
      subject { authority.search('whatever') }
      before do
        stub_request(:get, /vocab\.getty\.edu.*/)
          .to_return(body: webmock_fixture("aat-response.txt"), status: 200)
      end

      it "has id and label keys" do
        expect(subject.first).to eq("id" => 'http://vocab.getty.edu/aat/300053264', "label" => "photocopying")
        expect(subject.last).to eq("id" => 'http://vocab.getty.edu/aat/300265560', "label" => "photoscreenprints")
        expect(subject.size).to eq(10)
      end

      context 'when Getty returns an error,' do
        before do
          stub_request(:get, /vocab\.getty\.edu.*/)
            .to_return(body: webmock_fixture("getty-error-response.txt"), status: 500)
        end

        it 'logs error and returns empty results' do
          expect(Rails.logger).to receive(:warn).with("  ERROR fetching Getty response: undefined method `[]' for nil:NilClass; cause: UNKNOWN")
          expect(subject).to be {}
        end
      end
    end
  end

  describe "#untaint" do
    subject { authority.untaint(value) }

    context "with a good string" do
      let(:value) { 'Water-color paint' }
      it { is_expected.to eq 'Water-color paint' }
    end

    context "bad stuff" do
      let(:value) { './"' }
      it { is_expected.to eq '' }
    end
  end

  describe "#find" do
    context "using a subject id" do
      subject { authority.find("300265560") }
      before do
        stub_request(:get, "http://vocab.getty.edu/download/json?uri=http://vocab.getty.edu/aat/300265560.json")
          .to_return(status: 200, body: webmock_fixture("getty-aat-find-response.json"))
      end

      it "returns the complete record for a given subject" do
        expect(subject['results']['bindings'].size).to eq 189
        expect(subject['results']['bindings']).to all(have_key('Subject'))
        expect(subject['results']['bindings']).to all(have_key('Predicate'))
        expect(subject['results']['bindings']).to all(have_key('Object'))
      end
    end
  end

  describe "#request_options" do
    subject { authority.request_options }
    it { is_expected.to eq(accept: "application/sparql-results+json") }
  end
  # rubocop:disable Layout/LineLength
  describe "#sparql" do
    context "using a single subject term" do
      subject { authority.sparql('search_term') }
      it {
        is_expected.to eq %(SELECT ?s ?name { ?s a skos:Concept; luc:term "search_term"; skos:inScheme <http://vocab.getty.edu/aat/> ; gvp:prefLabelGVP [skosxl:literalForm ?name]. FILTER regex(?name, "search_term", "i") . } ORDER BY ?name)
      }
    end
    context "using a two subject terms" do
      subject { authority.sparql('search term') }
      it {
        is_expected.to eq %(SELECT ?s ?name { ?s a skos:Concept; luc:term "search term"; skos:inScheme <http://vocab.getty.edu/aat/> ; gvp:prefLabelGVP [skosxl:literalForm ?name]. FILTER ((regex(?name, "search", "i")) && (regex(?name, "term", "i"))) . } ORDER BY ?name)
      }
    end
  end
  # rubocop:enable Layout/LineLength
end
