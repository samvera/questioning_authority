require 'spec_helper'

describe Qa::Authorities::AssignFast do
  # subauthority infrastructure
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
        expect(described_class.subauthority_for("all")).to be_kind_of Qa::Authorities::AssignFast::GenericAuthority
      end
    end
  end

  # api call
  describe "query url" do
    let :authority do
      described_class.subauthority_for("all")
    end

    it "is correctly formed" do
      url = 'http://fast.oclc.org/searchfast/fastsuggest?&query=word%20ling&queryIndex=suggestall&queryReturn=suggestall%2Cidroot%2Cauth%2Ctype&suggest=autoSubject&rows=20'
      expect(authority.build_query_url("word (ling")).to eq(url)
    end
  end

  describe "search result" do
    let :authority do
      described_class.subauthority_for("all")
    end

    context "when we sent a bad character" do
      # server returns 200 with empty response; JSON throws a ParserError
      before do
        stub_request(:get, "http://fast.oclc.org/searchfast/fastsuggest?query=word%20ling&queryIndex=suggestall&queryReturn=suggestall,idroot,auth,type&rows=20&suggest=autoSubject")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(status: 200, body: "", headers: {})
      end
      it "logs an info and returns an empty array" do
        expect(Rails.logger).to receive(:info).with("Could not parse response as JSON. Request url: http://fast.oclc.org/searchfast/fastsuggest?&query=word%20ling&queryIndex=suggestall&queryReturn=suggestall%2Cidroot%2Cauth%2Ctype&suggest=autoSubject&rows=20")
        results = authority.search("word (ling")
        expect(results).to eq([])
      end
    end

    context "when query is blank" do
      # server returns results but no results header
      let :results do
        stub_request(:get, "http://fast.oclc.org/searchfast/fastsuggest?&query=&queryIndex=suggestall&queryReturn=suggestall%2Cidroot%2Cauth%2Ctype&suggest=autoSubject&rows=20")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("assign-fast-noheader.json"), status: 200, headers: {})
        authority.search("")
      end
      it "returns an empty array" do
        expect(results).to eq([])
      end
    end

    context "with no results" do
      let :results do
        stub_request(:get, "http://fast.oclc.org/searchfast/fastsuggest?query=word%20ling&queryIndex=suggestall&queryReturn=suggestall,idroot,auth,type&rows=20&suggest=autoSubject")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("assign-fast-noresults.json"), status: 200, headers: {})
        authority.search("word (ling")
      end
      it "returns an empty array" do
        expect(results).to eq([])
      end
    end

    context "with suggestall results" do
      let :results do
        stub_request(:get, "http://fast.oclc.org/searchfast/fastsuggest?query=word%20ling&queryIndex=suggestall&queryReturn=suggestall,idroot,auth,type&rows=20&suggest=autoSubject")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("assign-fast-oneresult.json"), status: 200, headers: {})
        authority.search("word (ling")
      end
      it "is correctly parsed" do
        expect(results.count).to eq(1)
        expect(results.first[:id]).to eq('fst01180101')
        expect(results.first[:label]).to eq('Word (Linguistics)')
        expect(results.first[:value]).to eq('Word (Linguistics)')
        expect(results.first).to eq(id: "fst01180101", label: "Word (Linguistics)", value: "Word (Linguistics)")
      end
    end

    context "with topical results" do
      let :results do
        stub_request(:get, "http://fast.oclc.org/searchfast/fastsuggest?query=word&queryIndex=suggest50&queryReturn=suggest50,idroot,auth,type&rows=20&suggest=autoSubject")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("assign-fast-topical-result.json"), status: 200, headers: {})
        described_class.subauthority_for("topical").search("word")
      end
      it "is correctly parsed" do
        expect(results.count).to eq(20)
        expect(results.first[:id]).to eq('fst01168328')
        expect(results.first[:label]).to eq('Word books USE Vocabulary')
        expect(results.first[:value]).to eq('Vocabulary')
      end
    end
  end
end
