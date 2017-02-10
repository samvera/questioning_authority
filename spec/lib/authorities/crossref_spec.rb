require 'spec_helper'
describe Qa::Authorities::Crossref do
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
        expect(described_class.subauthority_for("funders")).to be_kind_of Qa::Authorities::Crossref::GenericAuthority
      end
    end
  end

  describe "#urls" do
    let :authority do
      described_class.subauthority_for("funders")
    end

    context "for searching" do
      let(:url) { 'http://api.crossref.org/funders?query=heart' }
      it "returns a url" do
        expect(authority.build_query_url("heart")).to eq(url)
      end
    end

    context "for returning single terms" do
      let(:url) { 'http://api.crossref.org/funders/100011056' }
      it "returns a url with an authority and id" do
        expect(authority.find_url("100011056")).to eq(url)
      end
    end
  end

  describe "#search funders" do
    let :authority do
      described_class.subauthority_for("funders")
    end

    context "when query is blank" do
      # server returns results but no results header
      let :results do
        stub_request(:get, "http://api.crossref.org/funders?query=")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("funders-noquery.json"), status: 200, headers: {})
        authority.search("")
      end
      it "returns 20 results" do
        expect(results.length).to eq(20)
      end
    end

    context "with no results" do
      let :results do
        stub_request(:get, "http://api.crossref.org/funders?query=supercalafragalistic")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("funders-noresults.json"), status: 200, headers: {})
        authority.search("supercalafragalistic")
      end
      it "returns an empty array" do
        expect(results).to eq([])
      end
    end

    context "with funder results" do
      let :results do
        stub_request(:get, "http://api.crossref.org/funders?query=heart")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("funders-result.json"), status: 200, headers: {})
        described_class.subauthority_for("funders").search("heart")
      end
      it "is correctly parsed" do
        expect(results.count).to eq(20)
        expect(results.first[:id]).to eq('100011056')
        expect(results.first[:uri]).to eq('http://dx.doi.org/10.13039/100011056')
        expect(results.first[:label]).to eq('British Society for Heart Failure, (BSH), United Kingdom')
        expect(results.first[:value]).to eq('British Society for Heart Failure')
      end
    end
  end

  describe "#search journals" do
    let :authority do
      described_class.subauthority_for("journals")
    end

    context "when query is blank" do
      # server returns results but no results header
      let :results do
        stub_request(:get, "http://api.crossref.org/journals?query=")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("journals-noquery.json"), status: 200, headers: {})
        authority.search("")
      end
      it "returns 20 results" do
        expect(results.length).to eq(20)
      end
    end

    context "with no results" do
      let :results do
        stub_request(:get, "http://api.crossref.org/journals?query=supercalafragalistic")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("journals-noresults.json"), status: 200, headers: {})
        authority.search("supercalafragalistic")
      end
      it "returns an empty array" do
        expect(results).to eq([])
      end
    end

    context "with journal results" do
      let :results do
        stub_request(:get, "http://api.crossref.org/journals?query=heart")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("journals-result.json"), status: 200, headers: {})
        described_class.subauthority_for("journals").search("heart")
      end
      it "is correctly parsed" do
        expect(results.count).to eq(20)
        expect(results.first[:id]).to eq('1024-8714')
        expect(results.first[:label]).to eq('Bangladesh Heart Journal')
        expect(results.first[:publisher]).to eq('Bangladesh Journals Online')
      end
    end
  end

  describe "#find" do
    context "using a funder id" do
      let :subject do
        stub_request(:get, "http://api.crossref.org/funders/100011056")
          .to_return(status: 200, body: webmock_fixture("funders-find-response.json"))
        described_class.subauthority_for("funders").find("100011056")
      end

      it "returns the complete record for a given funder" do
        expect(subject['message']['id']).to eq '100011056'
        expect(subject['message']['name']).to eq "British Society for Heart Failure"
      end
    end
    context "using an issn" do
      let :subject do
        stub_request(:get, "http://api.crossref.org/journals/1024-8714")
          .to_return(status: 200, body: webmock_fixture("journals-find-response.json"))
        described_class.subauthority_for("journals").find("1024-8714")
      end

      it "returns the complete record for the given journal" do
        expect(subject['message']['ISSN']).to eq ['1024-8714']
        expect(subject['message']['title']).to eq "Bangladesh Heart Journal"
      end
    end
    context "using a journal with two issns" do
      let :issn do
        stub_request(:get, "http://api.crossref.org/journals/1941-3289")
          .to_return(status: 200, body: webmock_fixture("journals-find-response-two-issn.json"))
        described_class.subauthority_for("journals").find("1941-3289")
      end
      let :issn2 do
        stub_request(:get, "http://api.crossref.org/journals/1941-3297")
          .to_return(status: 200, body: webmock_fixture("journals-find-response-two-issn.json"))
        described_class.subauthority_for("journals").find("1941-3297")
      end

      it "returns the complete record for the given journal with either issn" do
        expect(issn['message']['ISSN']).to eq ["1941-3289", "1941-3297"]
        expect(issn2['message']['ISSN']).to eq ["1941-3289", "1941-3297"]
      end
    end
  end
end
