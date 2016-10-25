require 'spec_helper'

describe Qa::Authorities::Getty::TGN do
  let(:authority) { described_class.new }

  describe "#build_query_url" do
    subject { authority.build_query_url("foo") }
    it { is_expected.to match(/^http:\/\/vocab\.getty\.edu\//) }
  end

  describe "#find_url" do
    subject { authority.find_url("1028772") }
    it { is_expected.to eq "http://vocab.getty.edu/tgn/1028772.json" }
  end

  describe "#search" do
    context "authorities" do
      before do
        stub_request(:get, /vocab\.getty\.edu.*/)
          .to_return(body: webmock_fixture("tgn-response.txt"), status: 200)
      end

      subject { authority.search('whatever') }

      it "has id and label keys" do
        expect(subject.first).to eq("id" => 'http://vocab.getty.edu/tgn/2058300', "label" => "Cawood (Andrew, Missouri, United States)")
        expect(subject.last).to eq("id" => 'http://vocab.getty.edu/tgn/7022503', "label" => "Cawood Branch (Kentucky, United States)")
        expect(subject.size).to eq(6)
      end
    end
  end

  describe "#untaint" do
    subject { authority.untaint(value) }

    context "with a good string" do
      let(:value) { 'Cawood' }
      it { is_expected.to eq 'Cawood' }
    end

    context "bad stuff" do
      let(:value) { './"' }
      it { is_expected.to eq '' }
    end
  end

  describe "#find" do
    context "using a subject id" do
      before do
        stub_request(:get, "http://vocab.getty.edu/tgn/1028772.json")
          .to_return(status: 200, body: webmock_fixture("getty-tgn-find-response.json"))
      end
      subject { authority.find("1028772") }

      it "returns the complete record for a given subject" do
        expect(subject['results']['bindings'].size).to eq 103
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
      it { is_expected.to eq 'SELECT DISTINCT ?s ?name ?par {
              ?s a skos:Concept; luc:term "search_term";
                 skos:inScheme <http://vocab.getty.edu/tgn/> ;
                 gvp:prefLabelGVP [skosxl:literalForm ?name] ;
                  gvp:parentString ?par .
              FILTER regex(?name, "search_term", "i") .
            } ORDER BY ?name ASC(?par)' }
    end
    context "using a two subject terms" do
      subject { authority.sparql('search term') }
      it { is_expected.to eq "SELECT DISTINCT ?s ?name ?par {
              ?s a skos:Concept; luc:term \"search term\";
                 skos:inScheme <http://vocab.getty.edu/tgn/> ;
                 gvp:prefLabelGVP [skosxl:literalForm ?name] ;
                  gvp:parentString ?par .
              FILTER ((regex(CONCAT(?name, ', ', REPLACE(str(?par), \",[^,]+,[^,]+$\", \"\")), \"search\",\"i\" ) && regex(CONCAT(?name, ', ', REPLACE(str(?par), \",[^,]+,[^,]+$\", \"\")), \"term\",\"i\" ) ) && (regex(?name, \"search\",\"i\" ) || regex(?name, \"term\",\"i\" ) ) ) .
            } ORDER BY ?name ASC(?par)" }
    end
  end
end
