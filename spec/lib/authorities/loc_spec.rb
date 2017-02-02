require 'spec_helper'

describe Qa::Authorities::Loc do
  describe "#new" do
    context "without a sub-authority" do
      it "raises an exception" do
        expect { described_class.new }.to raise_error RuntimeError, "Initializing with as sub authority is removed. use Module.subauthority_for(nil) instead"
      end
    end
  end

  describe "#subauthority_for" do
    context "with an invalid sub-authority" do
      it "raises an exception" do
        expect { described_class.subauthority_for("foo") }.to raise_error Qa::InvalidSubAuthority
      end
    end
    context "with a valid sub-authority" do
      it "creates the authority" do
        expect(described_class.subauthority_for("subjects")).to be_kind_of Qa::Authorities::Loc::GenericAuthority
      end
    end
  end

  describe "urls" do
    let :authority do
      described_class.subauthority_for("subjects")
    end

    context "for searching" do
      let(:url) { 'http://id.loc.gov/search/?q=foo&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2Fsubjects&format=json' }
      it "returns a url" do
        expect(authority.build_query_url("foo")).to eq(url)
      end
    end

    context "for returning single terms" do
      let(:url) { "http://id.loc.gov/authorities/subjects/sh2002003586.json" }
      it "returns a url with an authority and id" do
        expect(authority.find_url("sh2002003586")).to eq(url)
      end
    end
  end

  describe "#response" do
    subject { authority.response(url) }
    let :authority do
      described_class.subauthority_for("subjects")
    end

    before do
      stub_request(:get, "http://id.loc.gov/search/?format=json&q=cs:http://id.loc.gov/authorities/subjects")
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(status: 200, body: "")
    end

    context "with flat params encoded" do
      let(:url) { 'http://id.loc.gov/search/?q=foo&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2Fsubjects&format=json' }
      it "returns a response" do
        flat_params_url = "http://id.loc.gov/search/?format=json&q=foo&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2Fsubjects"
        expect(subject.env.url.to_s).to eq(flat_params_url)
      end
    end
  end

  describe "#search" do
    context "any LOC authorities" do
      let :authority do
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=s&q=cs:http://id.loc.gov/vocabulary/geographicAreas")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("loc-response.txt"), status: 200)
        described_class.subauthority_for("geographicAreas")
      end

      it "retains the raw response from the LC service in JSON" do
        expect { authority.search("s") }.to change { authority.raw_response }
          .from(nil)
          .to(JSON.parse(webmock_fixture("loc-response.txt").read))
      end

      describe "the returned results" do
        let :results do
          authority.search("s")
        end

        it "has :id and :label elements" do
          expect(results.first["label"]).to eq("West (U.S.)")
          expect(results.first["id"]).to eq("info:lc/vocabulary/geographicAreas/n-usp")
          expect(results.last["label"]).to eq("Baltic States")
          expect(results.last["id"]).to eq("info:lc/vocabulary/geographicAreas/eb")
          expect(results.size).to eq(20)
        end
      end
    end

    context "subject terms" do
      let :results do
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=History--&q=cs:http://id.loc.gov/authorities/subjects")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("loc-subjects-response.txt"), status: 200)
        described_class.subauthority_for("subjects").search("History--")
      end
      it "has a URI for the id and a string label" do
        expect(results.count).to eq(20)
        expect(results.first["label"]).to eq("History--Philosophy--History--20th century")
        expect(results.first["id"]).to eq("info:lc/authorities/subjects/sh2008121753")
        expect(results[1]["label"]).to eq("History--Philosophy--History--19th century")
        expect(results[1]["id"]).to eq("info:lc/authorities/subjects/sh2008121752")
      end
    end

    context "name terms" do
      let :results do
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=Berry&q=cs:http://id.loc.gov/authorities/names")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("loc-names-response.txt"), status: 200)
        described_class.subauthority_for("names").search("Berry")
      end
      it "retrieves names via search" do
        expect(results.first["label"]).to eq("Berry, James W. (James William), 1938-")
      end
    end
  end

  describe "#find" do
    context "using a subject id" do
      let :results do
        stub_request(:get, "http://id.loc.gov/authorities/subjects/sh2002003586.json")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(status: 200, body: webmock_fixture("loc-subject-find-response.txt"), headers: {})
        described_class.subauthority_for("subjects").find("sh2002003586")
      end
      it "returns the complete record for a given subject" do
        expect(results.count).to eq(20)
        expect(results.first).to be_kind_of(Hash)
      end
    end
  end
end
