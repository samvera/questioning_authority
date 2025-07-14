require 'spec_helper'

describe Qa::Authorities::Discogs::GenericAuthority do
  before do
    described_class.discogs_key = 'dummy_key'
    described_class.discogs_secret = 'dummy_secret'
    described_class.discogs_user_token = nil
  end

  let(:authority) { described_class.new "all" }

  describe "#build_query_url" do
    context "build_query_url startRecord" do
      subject { authority.build_query_url("foo", tc) }
      let(:tc) { instance_double(Qa::TermsController) }
      before do
        allow(Qa::TermsController).to receive(:new).and_return(tc)
        allow(tc).to receive(:params).and_return('startRecord' => "16", 'maxRecords' => "5", 'subauthority' => "master")
      end

      it { is_expected.to eq 'https://api.discogs.com/database/search?q=foo&type=master&page=4&per_page=5&key=dummy_key&secret=dummy_secret' }
    end
    context "build_query_url per_page" do
      subject { authority.build_query_url("foo", tc) }
      let(:tc) { instance_double(Qa::TermsController) }
      before do
        allow(Qa::TermsController).to receive(:new).and_return(tc)
        allow(tc).to receive(:params).and_return('page' => "1", 'per_page' => "10", 'subauthority' => "master")
      end

      it { is_expected.to eq 'https://api.discogs.com/database/search?q=foo&type=master&page=1&per_page=10&key=dummy_key&secret=dummy_secret' }
    end

    context "with a user token" do
      subject { authority.build_query_url("foo", tc) }
      let(:tc) { instance_double(Qa::TermsController) }
      before do
        described_class.discogs_user_token = 'dummy_token'
        allow(Qa::TermsController).to receive(:new).and_return(tc)
        allow(tc).to receive(:params).and_return('page' => "1", 'per_page' => "10", 'subauthority' => "master")
      end

      it { is_expected.to eq 'https://api.discogs.com/database/search?q=foo&type=master&page=1&per_page=10' }
    end
  end

  describe "#find_url" do
    subject { authority.find_url("10018955", "release") }
    it { is_expected.to eq "https://api.discogs.com/releases/10018955" }
  end

  describe "#find" do
    context "find variations" do
      before do
        stub_request(:get, "https://api.discogs.com/releases/3380671")
          .to_return(status: 200, body: webmock_fixture("discogs-find-response-json.json"))

        stub_request(:get, "https://api.discogs.com/masters/3380671")
          .to_return(status: 200, body: webmock_fixture("discogs-id-not-found-master.json"))

        stub_request(:get, "https://api.discogs.com/masters/1234567")
          .to_return(status: 200, body: webmock_fixture("discogs-id-matches-master.json"))

        stub_request(:get, "https://api.discogs.com/releases/1234567")
          .to_return(status: 200, body: webmock_fixture("discogs-id-matches-release.json"))

        stub_request(:get, "https://api.discogs.com/masters/123459876")
          .to_return(status: 200, body: webmock_fixture("discogs-id-not-found-master.json"))

        stub_request(:get, "https://api.discogs.com/releases/123459876")
          .to_return(status: 200, body: webmock_fixture("discogs-id-not-found-release.json"))

        stub_request(:get, "https://api.discogs.com/releases/7143179")
          .to_return(status: 200, body: webmock_fixture("discogs-find-response-jsonld-release.json"))

        stub_request(:get, "https://api.discogs.com/masters/7143179")
          .to_return(status: 200, body: webmock_fixture("discogs-id-not-found-master.json"))

        stub_request(:get, "https://api.discogs.com/masters/950011")
          .to_return(status: 200, body: webmock_fixture("discogs-find-response-jsonld-master.json"))
      end

      context "json format and release subauthority" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          authority.find("3380671", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('format' => "json", 'subauthority' => "release")
        end

        it "returns the Discogs data for a given id" do
          expect(results['title']).to eq "A Swingin' Affair"
          expect(results['genres'][0]).to eq "Jazz"
        end
      end

      context "json format and subauthority all" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          authority.find("3380671", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('format' => "json", 'subauthority' => "all")
        end

        it "returns the Discogs data for a given id" do
          expect(results['title']).to eq "A Swingin' Affair"
          expect(results['genres'][0]).to eq "Jazz"
        end
      end

      context "id matches a Discogs release and a master" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          authority.find("1234567", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('format' => "json", 'subauthority' => "all")
        end

        it "returns two matches message and resource urls" do
          expect(results['message']).to eq "Both a master and a release match the requested ID."
          expect(results['resource_url'][0]).to eq "https://api.discogs.com/masters/1234567"
          expect(results['resource_url'][1]).to eq "https://api.discogs.com/releases/1234567"
        end
      end

      context "id matches neither a release nor a master" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          authority.find("123459876", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('format' => "json", 'subauthority' => "all")
        end

        it "returns two matches message and resource urls" do
          expect(results['message']).to eq "Neither a master nor a release matches the requested ID."
        end
      end

      context "json-ld format and subauthority master" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          authority.find("950011", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('format' => "jsonld", 'subauthority' => "master")
        end

        it "returns the Discogs data converted to json-ld for a given id" do
          expect(JSON.parse(results).keys).to match_array ["@context", "@graph"]
          expect(JSON.parse(results)["@context"]["bf2"]).to eq("http://id.loc.gov/ontologies/bibframe/")
          expect(results).to include("Blue Moon / You Go To My Head")
          expect(results).to include("Billie Holiday And Her Orchestra")
          expect(results).to include("Haven Gillespie")
          expect(results).to include("1952")
          expect(results).to include("Jazz")
          expect(results).to include("Barney Kessel")
          expect(results).to include("Guitar")
        end
      end

      context "n3 format and subauthority master" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          authority.find("950011", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('format' => "n3", 'subauthority' => "master")
        end

        it "returns the Discogs data converted to n3 for a given id" do
          expect(results).to start_with "@prefix"
          expect(results).to include("Blue Moon / You Go To My Head")
          expect(results).to include("Billie Holiday And Her Orchestra")
          expect(results).to include("Haven Gillespie")
          expect(results).to include("1952")
          expect(results).to include("Jazz")
          expect(results).to include("Barney Kessel")
          expect(results).to include("Guitar")
        end
      end

      context "ntriples format and subauthority master" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          authority.find("950011", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('format' => "ntriples", 'subauthority' => "master")
        end

        it "returns the Discogs data converted to ntriples for a given id" do
          expect(results).to include("https://www.discogs.com/Billie-Holiday-And-Her-Orchestra-Blue-Moon-You-Go-To-My-Head/master/950011")
          expect(results).to include("Blue Moon / You Go To My Head")
          expect(results).to include("Billie Holiday And Her Orchestra")
          expect(results).to include("Haven Gillespie")
          expect(results).to include("1952")
          expect(results).to include("Jazz")
          expect(results).to include("Barney Kessel")
          expect(results).to include("Guitar")
        end
      end

      context "json-ld format and subauthority all" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          authority.find("7143179", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('format' => "jsonld", 'subauthority' => "all")
        end

        it "returns the Discogs data converted to json-ld for a given id" do
          expect(JSON.parse(results).keys).to match_array ["@context", "@graph"]
          expect(JSON.parse(results)["@context"]["bf2"]).to eq("http://id.loc.gov/ontologies/bibframe/")
          expect(results).to include("You Go To My Head")
          expect(JSON.parse(results).inspect).to include("Rodgers & Hart")
          expect(results).to include("Ray Brown")
          expect(results).to include("1952")
          expect(results).to include("Single")
          expect(results).to include("mono")
          expect(results).to include("45 RPM")
          expect(results).to include("Vinyl")
          expect(results).to include("http://id.loc.gov/vocabulary/carriers/sd")
          expect(results).to include("1952")
        end
      end

      context "n3 format and subauthority all" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          authority.find("7143179", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('format' => "n3", 'subauthority' => "all")
        end

        it "returns the Discogs data converted to n3 for a given id" do
          expect(results).to start_with "@prefix"
          expect(results).to include("You Go To My Head")
          expect(results).to include("Rodgers & Hart")
          expect(results).to include("Ray Brown")
          expect(results).to include("1952")
          expect(results).to include("Single")
          expect(results).to include("mono")
          expect(results).to include("45 RPM")
          expect(results).to include("Vinyl")
          expect(results).to include("http://id.loc.gov/vocabulary/carriers/sd")
          expect(results).to include("1952")
        end
      end

      context "ntriples format and subauthority all" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          authority.find("7143179", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('format' => "ntriples", 'subauthority' => "all")
        end

        it "returns the Discogs data converted to ntriples for a given id" do
          expect(results).to include("https://www.discogs.com/Billie-Holiday-And-Her-Orchestra-Blue-Moon-You-Go-To-My-Head/release/7143179")
          expect(results).to include("You Go To My Head")
          expect(results).to include("Rodgers & Hart")
          expect(results).to include("Ray Brown")
          expect(results).to include("1952")
          expect(results).to include("Single")
          expect(results).to include("mono")
          expect(results).to include("45 RPM")
          expect(results).to include("Vinyl")
          expect(results).to include("http://id.loc.gov/vocabulary/carriers/sd")
          expect(results).to include("1952")
        end
      end
    end
  end

  describe "#search" do
    context "search variations" do
      context "with subauthority all" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          stub_request(:get, "https://api.discogs.com/database/search?q=melody+gardot+who+will+comfort+me+over+the+rainbo&type=all&page=&per_page=&key=dummy_key&secret=dummy_secret")
            .to_return(status: 200, body: webmock_fixture("discogs-search-response-no-subauth.json"))
          authority.search("melody gardot who will comfort me over the rainbo", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('subauthority' => "all")
        end

        it "has id and label keys" do
          expect(results.first["uri"]).to eq("https://www.discogs.com/Melody-Gardot-Who-Will-Comfort-Me-Over-The-Rainbow/release/1750352")
          expect(results.first["id"]).to eq "1750352"
          expect(results.first["label"]).to eq "Melody Gardot - Who Will Comfort Me / Over The Rainbow"
          expect(results.first["context"][1]["values"]).to eq ["2009"]
          expect(results.first["context"][3]["values"][0]).to eq "Vinyl"
          expect(results.first["context"][2]["values"][1]).to eq "Universal Music Classics & Jazz"
          expect(results.first["context"][4]["values"][0]).to eq "release"
        end
      end

      context "with subauthority master" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          stub_request(:get, "https://api.discogs.com/database/search?q=wes+montgomery+tequila+bumpin'+on+sunse&type=master&page=&per_page=&key=dummy_key&secret=dummy_secret")
            .to_return(status: 200, body: webmock_fixture("discogs-search-response-subauth.json"))
          authority.search("wes montgomery tequila bumpin' on sunse", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('subauthority' => "master")
        end

        it "has id and label keys" do
          expect(results.first['uri']).to eq "https://www.discogs.com/Wes-Montgomery-Bumpin-On-Sunset-Tequila/master/606116"
          expect(results.first['id']).to eq "606116"
          expect(results.first['label']).to eq "Wes Montgomery - Bumpin' On Sunset / Tequila"
          expect(results.first['context'][1]["values"]).to eq ['1966']
          expect(results.first['context'][3]["values"][2]).to eq "45 RPM"
          expect(results.first["context"][4]["values"][0]).to eq "master"
        end
      end

      context "with setRecord and maxRecords" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          stub_request(:get, "https://api.discogs.com/database/search?q=james+taylor+new+moon+shine&type=master&page=4&per_page=5&key=dummy_key&secret=dummy_secret")
            .to_return(status: 200, body: webmock_fixture("discogs-search-response-set-record.json"))
          authority.search("james taylor new moon shine", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('subauthority' => "master", 'startRecord' => 16, 'maxRecords' => 5, 'response_header' => 'true')
        end

        it "has id and label keys" do
          expect(results['response_header']['start_record']).to eq 16
          expect(results['response_header']['requested_records']).to eq 5
          expect(results['response_header']['retrieved_records']).to eq 2
          expect(results['response_header']['total_records']).to eq 17
        end
      end

      context "with page and per_page" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          stub_request(:get, "https://api.discogs.com/database/search?q=james+taylor+new+moon+shine&type=master&page=1&per_page=10&key=dummy_key&secret=dummy_secret")
            .to_return(status: 200, body: webmock_fixture("discogs-search-response-per-page.json"))
          authority.search("james taylor new moon shine", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('subauthority' => "master", 'page' => 1, 'per_page' => 10, 'response_header' => 'true')
        end

        it "has id and label keys" do
          expect(results['response_header']['start_record']).to eq 1
          expect(results['response_header']['requested_records']).to eq 10
          expect(results['response_header']['retrieved_records']).to eq 10
          expect(results['response_header']['total_records']).to eq 17
        end
      end

      context "with user token authentication" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          described_class.discogs_user_token = 'dummy_token'
          described_class.discogs_key = nil
          described_class.discogs_secret = nil
          stub_request(:get, "https://api.discogs.com/database/search?q=melody+gardot&type=all&page=&per_page=")
            .with(
              headers: {
                'Authorization' => 'Discogs token=dummy_token',
                'User-Agent' => 'HykuApp/1.0'
              }
            )
            .to_return(status: 200, body: webmock_fixture("discogs-search-response-no-subauth.json"))
          authority.search("melody gardot", tc)
        end
        before do
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('subauthority' => "all")
        end

        it "has id and label keys" do
          expect(results.first["uri"]).to eq("https://www.discogs.com/Melody-Gardot-Who-Will-Comfort-Me-Over-The-Rainbow/release/1750352")
          expect(results.first["id"]).to eq "1750352"
        end
      end

      context "when authentication isn't set" do
        let(:tc) { instance_double(Qa::TermsController) }
        let :results do
          stub_request(:get, "https://api.discogs.com/database/search?q=wes+montgomery+tequila+bumpin'+on+sunse&type=master")
            .to_return(status: 200, body: webmock_fixture("discogs-search-response-no-auth.json"))
          authority.search("wes montgomery tequila bumpin' on sunse", tc)
        end
        before do
          described_class.discogs_secret = nil
          described_class.discogs_key = nil
          described_class.discogs_user_token = nil
          allow(Qa::TermsController).to receive(:new).and_return(tc)
          allow(tc).to receive(:params).and_return('subauthority' => "master")
        end

        it "logs an error" do
          expect(Rails.logger).to receive(:error).with('Questioning Authority tried to call Discogs, but no user token, secret and/or key were set.')
          expect(results).to be_empty
        end
      end
    end
  end
end
