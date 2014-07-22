require 'spec_helper'

describe Qa::Authorities::Loc do

  describe "#new" do
    context "without a sub-authority" do
      it "should raise an exception" do
        expect { Qa::Authorities::Loc.new }.to raise_error
      end
    end
    context "with an invalid sub-authority" do
      it "should raise an exception" do
        expect { Qa::Authorities::Loc.new("foo") }.to raise_error
      end
    end
    context "with a valid sub-authority" do
      it "should create the authority" do
        expect(Qa::Authorities::Loc.new("subjects")).to be_kind_of Qa::Authorities::Loc
      end
    end
  end
    
  describe "urls" do

    let :authority do
      Qa::Authorities::Loc.new("subjects")
    end
    
    context "for searching" do
      it "should return a url" do
        url = 'http://id.loc.gov/search/?q=foo&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2Fsubjects&format=json'
        expect(authority.build_query_url("foo")).to eq(url)
      end
    end

    context "for returning single terms" do
      it "returns a url with an authority and id" do
        url = "http://id.loc.gov/authorities/subjects/sh2002003586.json"
        expect(authority.find_url("sh2002003586")).to eq(url)
      end
    end
  
  end

  describe "#search" do

    context "any LOC authorities" do
      let :authority do
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=s&q=cs:http://id.loc.gov/vocabulary/geographicAreas").
            with(:headers => {'Accept'=>'application/json'}).
            to_return(:body => webmock_fixture("loc-response.txt"), :status => 200)
        Qa::Authorities::Loc.new("geographicAreas")
      end

      it "should retain the raw respsonse from the LC service in JSON" do
        expect(authority.raw_response).to be_nil
        json = Qa::Authorities::WebServiceBase.new.get_json(authority.build_query_url("s"))
        authority.search("s")
        expect(authority.raw_response).to eq(json)
      end

      describe "the returned results" do

        let :results do
          authority.search("s")
        end

        it "should have :id and :label elements" do
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
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=History--&q=cs:http://id.loc.gov/authorities/subjects").
            with(:headers => {'Accept'=>'application/json'}).
            to_return(:body => webmock_fixture("loc-subjects-response.txt"), :status => 200)
        Qa::Authorities::Loc.new("subjects").search("History--")
      end
      it "should have a URI for the id and a string label" do
        expect(results.count).to eq(20)
        expect(results.first["label"]).to eq("History--Philosophy--History--20th century")
        expect(results.first["id"]).to eq("info:lc/authorities/subjects/sh2008121753")
        expect(results[1]["label"]).to eq("History--Philosophy--History--19th century")
        expect(results[1]["id"]).to eq("info:lc/authorities/subjects/sh2008121752")
      end
    end

    context "name terms" do
      let :results do
        stub_request(:get, "http://id.loc.gov/search/?format=json&q=Berry&q=cs:http://id.loc.gov/authorities/names").
            with(:headers => {'Accept'=>'application/json'}).
            to_return(:body => webmock_fixture("loc-names-response.txt"), :status => 200)
            Qa::Authorities::Loc.new("names").search("Berry")
      end
      it "should retrieve names via search" do
        expect(results.first["label"]).to eq("Berry, James W. (James William), 1938-")
      end
    end

  end

  describe "#find" do
    context "using a subject id" do
      let :results do
        stub_request(:get, "http://id.loc.gov/authorities/subjects/sh2002003586.json").
          with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => webmock_fixture("loc-subject-find-response.txt"), :headers => {})
        Qa::Authorities::Loc.new("subjects").find("sh2002003586")
      end
      it "returns the complete record for a given subject" do
        expect(results.count).to eq(20)
        expect(results.first).to be_kind_of(Hash)
      end
    end
  end

end
