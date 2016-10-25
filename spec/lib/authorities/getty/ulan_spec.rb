require 'spec_helper'

describe Qa::Authorities::Getty::Ulan do
  let(:authority) { described_class.new }

  describe "#build_query_url" do
    subject { authority.build_query_url("foo") }
    it { is_expected.to match(/^http:\/\/vocab\.getty\.edu\//) }
  end

  describe "#find_url" do
    subject { authority.find_url("500026846") }
    it { is_expected.to eq "http://vocab.getty.edu/ulan/500026846.json" }
  end

  describe "#search" do
    context "authorities" do
      before do
        stub_request(:get, /vocab\.getty\.edu.*/)
          .to_return(body: webmock_fixture("ulan-response.txt"), status: 200)
      end

      subject { authority.search('whatever') }

      it "has id and label keys" do
        expect(subject.first).to eq("id" => 'http://vocab.getty.edu/ulan/500233743', "label" => "Alan Turner and Associates (British architectural firm, contemporary)")
        expect(subject.last).to eq("id" => 'http://vocab.getty.edu/ulan/500023812', "label" => "Warren, Charles Turner (English engraver, 1762-1823)")
        expect(subject.size).to eq(142)
      end
    end
  end

  describe "#untaint" do
    subject { authority.untaint(value) }

    context "with a good string" do
      let(:value) { 'Turner' }
      it { is_expected.to eq 'Turner' }
    end

    context "bad stuff" do
      let(:value) { './"' }
      it { is_expected.to eq '' }
    end
  end

  describe "#find" do
    context "using a subject id" do
      before do
        stub_request(:get, "http://vocab.getty.edu/ulan/500026846.json")
          .to_return(status: 200, body: webmock_fixture("getty-ulan-find-response.json"))
      end
      subject { authority.find("500026846") }

      it "returns the complete record for a given subject" do
        expect(subject['results']['bindings'].size).to eq 880
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

  describe "#sparql" do
    context "using a single subject term" do
      subject { authority.sparql('search_term') }
      it { is_expected.to eq 'SELECT DISTINCT ?s ?name ?bio {
              ?s a skos:Concept; luc:term "search_term";
                 skos:inScheme <http://vocab.getty.edu/ulan/> ;
                 gvp:prefLabelGVP [skosxl:literalForm ?name] ;
                 foaf:focus/gvp:biographyPreferred [schema:description ?bio] ;
                 skos:altLabel ?alt .
              FILTER regex(?name, "search_term", "i") .
            } ORDER BY ?name' }
    end
    context "using a two subject terms" do
      subject { authority.sparql('search term') }
      it { is_expected.to eq "SELECT DISTINCT ?s ?name ?bio {
              ?s a skos:Concept; luc:term \"search term\";
                 skos:inScheme <http://vocab.getty.edu/ulan/> ;
                 gvp:prefLabelGVP [skosxl:literalForm ?name] ;
                 foaf:focus/gvp:biographyPreferred [schema:description ?bio] ;
                 skos:altLabel ?alt .
              FILTER (regex(CONCAT(?name, ' ', ?alt), \"search\",\"i\" ) && regex(CONCAT(?name, ' ', ?alt), \"term\",\"i\" ) ) .
            } ORDER BY ?name" }
    end
  end
end
