require 'spec_helper'

describe Qa::TermsController, type: :controller do
  before do
    @routes = Qa::Engine.routes
  end

  describe "#check_vocab_param" do
    it "returns 400 if the vocabulary is missing" do
      get :search, params: { q: "a query", vocab: "" }
      expect(response.code).to eq("400")
    end
  end

  describe "#check_query_param" do
    it "returns 400 if the query is missing" do
      get :search, params: { q: "", vocab: "tgnlang" }
      expect(response.code).to eq("400")
    end
  end

  describe "#init_authority" do
    context "when the authority does not exist" do
      it "returns 400" do
        expect(Rails.logger).to receive(:warn).with("Unable to initialize authority Qa::Authorities::Non-existent-authority")
        get :search, params: { q: "a query", vocab: "non-existent-authority" }
        expect(response.code).to eq("400")
      end
    end
    context "when a sub-authority does not exist" do
      it "returns 400 if a sub-authority does not exist" do
        msg = "Unable to initialize sub-authority non-existent-subauthority for Qa::Authorities::Loc. Valid sub-authorities are " \
              "[\"subjects\", \"names\", \"classification\", \"childrensSubjects\", \"genreForms\", \"performanceMediums\", " \
              "\"graphicMaterials\", \"organizations\", \"relators\", \"countries\", \"ethnographicTerms\", \"geographicAreas\", " \
              "\"languages\", \"iso639-1\", \"iso639-2\", \"iso639-5\", \"preservation\", \"actionsGranted\", \"agentType\", " \
              "\"edtf\", \"contentLocationType\", \"copyrightStatus\", \"cryptographicHashFunctions\", " \
              "\"environmentCharacteristic\", \"environmentPurpose\", \"eventRelatedAgentRole\", \"eventRelatedObjectRole\", " \
              "\"eventType\", \"formatRegistryRole\", \"hardwareType\", \"inhibitorTarget\", \"inhibitorType\", \"objectCategory\", " \
              "\"preservationLevelRole\", \"relationshipSubType\", \"relationshipType\", \"rightsBasis\", \"rightsRelatedAgentRole\", " \
              "\"signatureEncoding\", \"signatureMethod\", \"softwareType\", \"storageMedium\"]"
        expect(Rails.logger).to receive(:warn).with(msg)
        get :search, params: { q: "a query", vocab: "loc", subauthority: "non-existent-subauthority" }
        expect(response.code).to eq("400")
      end
    end
    context "when a sub-authority is absent" do
      it "returns 400 for LOC" do
        get :search, params: { q: "a query", vocab: "loc" }
        expect(response.code).to eq("400")
      end
      it "returns 400 for oclcts" do
        get :search, params: { q: "a query", vocab: "oclcts" }
        expect(response.code).to eq("400")
      end
      it "returns 400 for discogs" do
        get :search, params: { q: "a query", vocab: "discogs" }
        expect(response.code).to eq("400")
      end
    end
  end

  describe "#search" do
    context "when a local authority expects two arguments" do
      before do
        class Qa::Authorities::Local::TwoArgs < Qa::Authorities::Base
          attr_reader :subauthority
          def initialize(subauthority)
            super()
            @subauthority = subauthority
          end

          def search(_arg1, _arg2)
            []
          end
        end
        Qa::Authorities::Local.register_subauthority('two_args', 'Qa::Authorities::Local::TwoArgs')
      end
      it "succeeds" do
        get :search, params: { q: "a query", vocab: "local", subauthority: "two_args" }
        expect(response).to be_successful
      end
    end

    context "loc" do
      before do
        stub_request(:get, "https://id.loc.gov/search/?format=json&q=Berry&q=cs:http://id.loc.gov/authorities/names")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("loc-names-response.txt"), status: 200)
      end

      it "returns a set of terms for a tgnlang query" do
        get :search, params: { q: "Tibetan", vocab: "tgnlang" }
        expect(response).to be_successful
      end

      it "does not return 400 if subauthority is valid" do
        get :search, params: { q: "Berry", vocab: "loc", subauthority: "names" }
        expect(response).to be_successful
      end

      context 'when cors headers are enabled' do
        before do
          Qa.config.enable_cors_headers
          stub_request(:get, "http://id.loc.gov/search/?format=json&q=Berry&q=cs:http://id.loc.gov/authorities/names")
            .with(headers: { 'Accept' => 'application/json' })
            .to_return(body: webmock_fixture("loc-names-response.txt"), status: 200)
        end
        it 'Access-Control-Allow-Origin is *' do
          get :search, params: { q: "Tibetan", vocab: "tgnlang" }
          expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
        end
      end

      context 'when cors headers are disabled' do
        before do
          Qa.config.disable_cors_headers
          stub_request(:get, "http://id.loc.gov/search/?format=json&q=Berry&q=cs:http://id.loc.gov/authorities/names")
            .with(headers: { 'Accept' => 'application/json' })
            .to_return(body: webmock_fixture("loc-names-response.txt"), status: 200)
        end
        it 'Access-Control-Allow-Origin is not present' do
          get :search, params: { q: "Tibetan", vocab: "tgnlang" }
          expect(response.headers.key?('Access-Control-Allow-Origin')).to be false
        end
      end

      context 'when pagination parameters are set' do
        context 'and no format is specified' do
          let(:params) do
            {
              q: "Berry", vocab: "loc", subauthority: "names",
              page_limit: "5", page_offset: "6"
            }
          end

          it "returns a subset of results as an Array<Hash>" do
            # query without pagination is expected to return 20 results
            get :search, params: params
            expect(response).to be_successful
            expect(response.content_type.split(';')).to include 'application/json'
            results = JSON.parse(response.body)
            expect(results.count).to eq 5
          end
        end

        context 'and format is specified as :jsonapi' do
          let(:params) do
            {
              q: "Berry", vocab: "loc", subauthority: "names",
              page_limit: "5", page_offset: "6", format: "jsonapi"
            }
          end
          let(:total_num_found) { "20" } # query without pagination is expected to return 20 results

          it "returns a subset of results in the JSON-API format" do
            get :search, params: params
            expect(response).to be_successful
            expect(response.content_type.split(';')).to include 'application/vnd.api+json'
            json_api_response = JSON.parse(response.body)
            expect(json_api_response['data'].count).to eq 5
          end

          it "sets meta['page'] stats" do
            get :search, params: params
            json_api_response = JSON.parse(response.body)
            expect(json_api_response["meta"]["page"]["page_offset"]).to eq "6"
            expect(json_api_response["meta"]["page"]["page_limit"]).to eq "5"
            expect(json_api_response["meta"]["page"]["actual_page_size"]).to eq "5"
            expect(json_api_response["meta"]["page"]["total_num_found"]).to eq total_num_found
          end

          it 'sets links with prev and next having values' do
            get :search, params: params

            base_url = request.base_url
            url_path = request.path
            first_page = "#{base_url}#{url_path}?q=Berry&page_limit=5&page_offset=1"
            second_page = "#{base_url}#{url_path}?q=Berry&page_limit=5&page_offset=6"
            third_page = "#{base_url}#{url_path}?q=Berry&page_limit=5&page_offset=11"
            fourth_page = "#{base_url}#{url_path}?q=Berry&page_limit=5&page_offset=16"
            last_page = fourth_page

            json_api_response = JSON.parse(response.body)
            expect(json_api_response['links']["self"]).to eq second_page
            expect(json_api_response['links']["first"]).to eq first_page
            expect(json_api_response['links']["prev"]).to eq first_page
            expect(json_api_response['links']["next"]).to eq third_page
            expect(json_api_response['links']["last"]).to eq last_page
          end

          it 'does not include errors' do
            get :search, params: params
            json_api_response = JSON.parse(response.body)
            expect(json_api_response.key?('errors')).to eq false
          end
        end
      end
    end

    context "assign_fast" do
      before do
        stub_request(:get, "http://fast.oclc.org/searchfast/fastsuggest?query=word&queryIndex=suggest50&queryReturn=suggest50,idroot,auth,type&rows=20&suggest=autoSubject&sort=usage+desc")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: webmock_fixture("assign-fast-topical-result.json"), status: 200, headers: {})
      end
      it "succeeds if authority class is camelcase" do
        get :search, params: { q: "word", vocab: "assign_fast", subauthority: "topical" }
        expect(response).to be_successful
      end
    end
  end

  describe "#index" do
    context "with supported authorities" do
      it "returns all local authority state terms" do
        get :index, params: { vocab: "local", subauthority: "states" }
        expect(response).to be_successful
      end
      it "returns all MeSH terms" do
        get :index, params: { vocab: "mesh" }
        expect(response).to be_successful
      end

      context 'when cors headers are enabled' do
        before do
          Qa.config.enable_cors_headers
        end
        it 'Access-Control-Allow-Origin is *' do
          get :index, params: { vocab: "local", subauthority: "states" }
          expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
        end
      end

      context 'when cors headers are disabled' do
        before do
          Qa.config.disable_cors_headers
        end
        it 'Access-Control-Allow-Origin is not present' do
          get :index, params: { vocab: "local", subauthority: "states" }
          expect(response.headers.key?('Access-Control-Allow-Origin')).to be false
        end
      end
    end

    context "when the authority does not support #all" do
      it "returns null for tgnlang" do
        get :index, params: { vocab: "tgnlang" }
        expect(response.body).to eq("null")
      end
      it "returns null for oclcts" do
        get :index, params: { vocab: "oclcts", subauthority: "mesh" }
        expect(response.body).to eq("null")
      end
      it "returns null for LOC authorities" do
        get :index, params: { vocab: "loc", subauthority: "relators" }
        expect(response.body).to eq("null")
      end
    end
  end

  describe "#show" do
    context "with supported authorities" do
      before do
        stub_request(:get, "https://id.loc.gov/authorities/subjects/sh85077565.json")
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(status: 200, body: webmock_fixture("loc-names-response.txt"), headers: {})
      end

      it "returns an individual state term" do
        get :show, params: { vocab: "local", subauthority: "states", id: "OH" }
        expect(response).to be_successful
      end

      it "returns an individual MeSH term" do
        get :show, params: { vocab: "mesh", id: "D000001" }
        expect(response).to be_successful
      end

      it "returns an individual subject term" do
        get :show, params: { vocab: "loc", subauthority: "subjects", id: "sh85077565" }
        expect(response).to be_successful
      end

      context 'when cors headers are enabled' do
        before do
          Qa.config.enable_cors_headers
        end
        it 'Access-Control-Allow-Origin is *' do
          get :show, params: { vocab: "mesh", id: "D000001" }
          expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
        end
      end

      context 'when cors headers are disabled' do
        before do
          Qa.config.disable_cors_headers
        end
        it 'Access-Control-Allow-Origin is not present' do
          get :show, params: { vocab: "mesh", id: "D000001" }
          expect(response.headers.key?('Access-Control-Allow-Origin')).to be false
        end
      end
    end
    context "with request for n3" do
      before do
        stub_request(:get, "https://api.discogs.com/releases/3380671")
          .to_return(status: 200, body: webmock_fixture("discogs-find-response-json.json"))
      end
      it 'Access-Control-Allow-Origin is not present' do
        get :show, params: { vocab: "discogs", subauthority: "release", id: "3380671", format: 'n3' }
        expect(response).to be_successful
        expect(response.media_type).to eq 'text/n3'
        expect(response.body).to start_with "@prefix"
      end
    end
    context "with request for ntriples" do
      before do
        stub_request(:get, "https://api.discogs.com/releases/3380671")
          .to_return(status: 200, body: webmock_fixture("discogs-find-response-json.json"))
      end
      it 'Access-Control-Allow-Origin is not present' do
        get :show, params: { vocab: "discogs", subauthority: "release", id: "3380671", format: 'ntriples' }
        expect(response).to be_successful
        expect(response.media_type).to eq 'application/n-triples'
        expect(response.body).to include('_:agentn1 <http://www.w3.org/2000/01/rdf-schema#label> "Dexter Gordon"')
      end
    end
  end

  describe "#fetch" do
    context "with supported authorities" do
      it "returns an individual state term" do
        get :fetch, params: { vocab: "local", subauthority: "authority_U", uri: "http://my.domain/terms/a2" }
        expect(response).to be_successful
      end

      context 'when cors headers are enabled' do
        before do
          Qa.config.enable_cors_headers
        end
        it 'Access-Control-Allow-Origin is *' do
          get :fetch, params: { vocab: "local", subauthority: "authority_U", uri: "http://my.domain/terms/a2" }
          expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
        end
      end

      context 'when cors headers are disabled' do
        before do
          Qa.config.disable_cors_headers
        end
        it 'Access-Control-Allow-Origin is not present' do
          get :fetch, params: { vocab: "local", subauthority: "authority_U", uri: "http://my.domain/terms/a2" }
          expect(response.headers.key?('Access-Control-Allow-Origin')).to be false
        end
      end
    end
  end
end
