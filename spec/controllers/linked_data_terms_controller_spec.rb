require 'spec_helper'
require 'json'

describe Qa::LinkedDataTermsController, type: :controller do
  before do
    @routes = Qa::Engine.routes
  end

  describe '#check_authority' do
    it 'for search returns 400 if the vocabulary is not specified' do
      expect(Rails.logger).to receive(:warn).with("Required param 'vocab' is missing or empty")
      get :search, params: { q: 'a query', vocab: '' }
      expect(response.code).to eq('400')
    end

    it 'for show returns 400 if the vocabulary is not specified' do
      expect(Rails.logger).to receive(:warn).with("Required param 'vocab' is missing or empty")
      get :show, params: { id: 'C_1234', vocab: '' }
      expect(response.code).to eq('400')
    end
  end

  describe '#check_search_subauthority' do
    it 'returns 400 if the query subauthority is missing' do
      expect(Rails.logger).to receive(:warn).with("Unable to initialize linked data search sub-authority '' for authority 'OCLC_FAST'")
      get :search, params: { q: 'test', vocab: 'OCLC_FAST', subauthority: '' }
      expect(response.code).to eq('400')
    end
    it 'returns 400 if the query subauthority is invalid' do
      expect(Rails.logger).to receive(:warn).with("Unable to initialize linked data search sub-authority 'FAKE_SUBAUTHORITY' for authority 'OCLC_FAST'")
      get :search, params: { vocab: 'OCLC_FAST', subauthority: 'FAKE_SUBAUTHORITY' }
      expect(response.code).to eq('400')
    end
  end

  describe '#check_show_subauthority' do
    it 'returns 400 if the show subauthority is missing' do
      expect(Rails.logger).to receive(:warn).with("Unable to initialize linked data term sub-authority '' for authority 'OCLC_FAST'")
      get :show, params: { id: 'C_123', vocab: 'OCLC_FAST', subauthority: '' }
      expect(response.code).to eq('400')
    end
    it 'returns 400 if the show subauthority is invalid' do
      expect(Rails.logger).to receive(:warn).with("Unable to initialize linked data term sub-authority 'FAKE_SUBAUTHORITY' for authority 'OCLC_FAST'")
      get :show, params: { id: 'C_123', vocab: 'OCLC_FAST', subauthority: 'FAKE_SUBAUTHORITY' }
      expect(response.code).to eq('400')
    end
  end

  describe '#check_query_param' do
    it 'returns 400 if the query is missing' do
      expect(Rails.logger).to receive(:warn).with("Required search param 'q' is missing or empty")
      get :search, params: { vocab: 'OCLC_FAST' }
      expect(response.code).to eq('400')
    end
  end

  describe '#check_id_param' do
    it 'returns 400 if the id is missing' do
      expect(Rails.logger).to receive(:warn).with("Required show param 'id' is missing or empty")
      get :show, params: { id: '', vocab: 'OCLC_FAST' }
      expect(response.code).to eq('400')
    end
  end

  describe '#check_uri_param' do
    it 'returns 400 if the uri is missing' do
      expect(Rails.logger).to receive(:warn).with("Required fetch param 'uri' is missing or empty")
      get :fetch, params: { uri: '', vocab: 'OCLC_FAST' }
      expect(response.code).to eq('400')
    end
  end

  describe '#init_authority' do
    context 'when the authority does not exist' do
      it 'returns 400' do
        expect(Rails.logger).to receive(:warn).with("Unable to initialize linked data authority 'FAKE_AUTHORITY'")
        get :search, params: { q: 'a query', vocab: 'fake_authority' }
        expect(response.code).to eq('400')
      end
    end
  end

  describe '#list' do
    let(:expected_results) { ['Auth1', 'Auth2', 'Auth3'] }
    before do
      allow(Qa::LinkedData::AuthorityService).to receive(:authority_names).and_return(expected_results)
    end
    it 'returns list of authorities' do
      get :list
      expect(response).to be_successful
      expect(response.body).to eq expected_results.to_json
    end
  end

  describe '#search' do
    context 'producing internal server error' do
      context 'when server returns 500' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22my_query%22&sortKeys=usage')
            .to_return(status: 500)
        end
        it 'returns 500' do
          expect(Rails.logger).to receive(:warn).with("Internal Server Error - Search query my_query unsuccessful for authority OCLC_FAST")
          get :search, params: { q: 'my_query', vocab: 'OCLC_FAST', maximumRecords: '3' }
          expect(response.code).to eq('500')
        end
      end

      context 'when rdf format error' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22my_query%22&sortKeys=usage')
            .to_return(status: 200)
          allow(RDF::Graph).to receive(:load).and_raise(RDF::FormatError)
        end
        it 'returns 500' do
          msg = "RDF Format Error - Results from search query my_query for authority OCLC_FAST was not identified as a valid RDF format.  You may need to include the linkeddata gem."
          expect(Rails.logger).to receive(:warn).with(msg)
          get :search, params: { q: 'my_query', vocab: 'OCLC_FAST', maximumRecords: '3' }
          expect(response.code).to eq('500')
        end
      end

      context "when error isn't specifically handled" do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22my_query%22&sortKeys=usage')
            .to_return(status: 501)
        end
        it 'returns 500' do
          expect(Rails.logger).to receive(:warn).with("Internal Server Error - Search query my_query unsuccessful for authority OCLC_FAST")
          get :search, params: { q: 'my_query', vocab: 'OCLC_FAST', maximumRecords: '3' }
          expect(response.code).to eq('500')
        end
      end
    end

    context 'when service unavailable' do
      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22my_query%22&sortKeys=usage')
          .to_return(status: 503)
      end
      it 'returns 503' do
        expect(Rails.logger).to receive(:warn).with("Service Unavailable - Search query my_query unsuccessful for authority OCLC_FAST")
        get :search, params: { q: 'my_query', vocab: 'OCLC_FAST', maximumRecords: '3' }
        expect(response.code).to eq('503')
      end
    end

    context 'in OCLC_FAST authority' do
      context '0 search results' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22supercalifragilisticexpialidocious%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_query_no_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :search, params: { q: 'supercalifragilisticexpialidocious', vocab: 'OCLC_FAST', maximumRecords: '3' }
          expect(response).to be_successful
        end
      end

      context '3 search results' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_all_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :search, params: { q: 'cornell', vocab: 'OCLC_FAST', maximumRecords: '3' }
          expect(response).to be_successful
        end
      end

      context '3 search results with blank nodes removed' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=5&query=cql.any%20all%20%22ezra%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_search_with_blanknode_subjects.nt'), headers: { 'Content-Type' => 'application/n-triples' })
        end
        it 'succeeds' do
          get :search, params: { q: 'ezra', vocab: 'OCLC_FAST', maximumRecords: '5' }
          expect(response).to be_successful
          results = JSON.parse(response.body)
          blank_nodes = results.select { |r| r['uri'].start_with?('_:b') }
          expect(blank_nodes.size).to eq 0
          expect(results.size).to eq 3
        end
      end
    end

    context 'in OCLC_FAST authority and personal_name subauthority' do
      context '0 search results' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=oclc.personalName%20all%20%22supercalifragilisticexpialidocious%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_query_no_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :search, params: { q: 'supercalifragilisticexpialidocious', vocab: 'OCLC_FAST', subauthority: 'personal_name', maximumRecords: '3' }
          expect(response).to be_successful
        end
      end

      context '3 search results' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=oclc.personalName%20all%20%22cornell%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_personalName_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :search, params: { q: 'cornell', vocab: 'OCLC_FAST', subauthority: 'personal_name', maximumRecords: '3' }
          expect(response).to be_successful
        end
      end

      context 'when cors headers are enabled' do
        before do
          Qa.config.enable_cors_headers
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=oclc.personalName%20all%20%22cornell%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_personalName_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'Access-Control-Allow-Origin is *' do
          get :search, params: { q: 'cornell', vocab: 'OCLC_FAST', subauthority: 'personal_name', maximumRecords: '3' }
          expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
        end
      end

      context 'when cors headers are disabled' do
        before do
          Qa.config.disable_cors_headers
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=oclc.personalName%20all%20%22cornell%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_personalName_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'Access-Control-Allow-Origin is not present' do
          get :search, params: { q: 'cornell', vocab: 'OCLC_FAST', subauthority: 'personal_name', maximumRecords: '3' }
          expect(response.headers.key?('Access-Control-Allow-Origin')).to be false
        end
      end
    end

    context 'when processing context' do
      before do
        Qa.config.disable_cors_headers
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 200, body: webmock_fixture('lod_oclc_all_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
      end
      it "returns basic data + context when context='true'" do
        get :search, params: { q: 'cornell', vocab: 'OCLC_FAST', maximumRecords: '3', context: 'true' }
        expect(response).to be_successful
        results = JSON.parse(response.body)
        expect(results.size).to eq 3
        expect(results.first.key?('context')).to be true
      end

      it "returns basic data only when context='false'" do
        get :search, params: { q: 'cornell', vocab: 'OCLC_FAST', maximumRecords: '3', context: 'false' }
        expect(response).to be_successful
        results = JSON.parse(response.body)
        expect(results.size).to eq 3
        expect(results.first.key?('context')).to be false
      end
    end
  end

  describe '#show' do
    context 'producing internal server error' do
      context 'when server returns 500' do
        before do
          stub_request(:get, 'http://id.worldcat.org/fast/530369').to_return(status: 500)
        end
        it 'returns 500' do
          expect(Rails.logger).to receive(:warn).with("Internal Server Error - Fetch term 530369 unsuccessful for authority OCLC_FAST")
          get :show, params: { id: '530369', vocab: 'OCLC_FAST' }
          expect(response.code).to eq('500')
        end
      end

      context 'when rdf format error' do
        before do
          stub_request(:get, 'http://id.worldcat.org/fast/530369').to_return(status: 200)
          allow(RDF::Graph).to receive(:load).and_raise(RDF::FormatError)
        end
        it 'returns 500' do
          msg = "RDF Format Error - Results from fetch term 530369 for authority OCLC_FAST was not identified as a valid RDF format.  You may need to include the linkeddata gem."
          expect(Rails.logger).to receive(:warn).with(msg)
          get :show, params: { id: '530369', vocab: 'OCLC_FAST' }
          expect(response.code).to eq('500')
        end
      end

      context "when error isn't specifically handled" do
        before do
          stub_request(:get, 'http://id.worldcat.org/fast/530369').to_return(status: 501)
        end
        it 'returns 500' do
          expect(Rails.logger).to receive(:warn).with("Internal Server Error - Fetch term 530369 unsuccessful for authority OCLC_FAST")
          get :show, params: { id: '530369', vocab: 'OCLC_FAST' }
          expect(response.code).to eq('500')
        end
      end
    end

    context 'when service unavailable' do
      before do
        stub_request(:get, 'http://id.worldcat.org/fast/530369').to_return(status: 503)
      end
      it 'returns 503' do
        expect(Rails.logger).to receive(:warn).with("Service Unavailable - Fetch term 530369 unsuccessful for authority OCLC_FAST")
        get :show, params: { id: '530369', vocab: 'OCLC_FAST' }
        expect(response.code).to eq('503')
      end
    end

    context 'when requested term is not found at the server' do
      before do
        stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID').to_return(status: 404, body: '', headers: {})
      end
      it 'returns 404' do
        expect(Rails.logger).to receive(:warn).with('Term Not Found - Fetch term FAKE_ID unsuccessful for authority OCLC_FAST')
        get :show, params: { id: 'FAKE_ID', vocab: 'OCLC_FAST' }
        expect(response.code).to eq('404')
      end
    end

    context 'in OCLC_FAST authority' do
      context 'term found' do
        before do
          stub_request(:get, 'http://id.worldcat.org/fast/530369')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds and defaults to json content type' do
          get :show, params: { id: '530369', vocab: 'OCLC_FAST' }
          expect(response).to be_successful
          expect(response.content_type).to eq 'application/json'
        end

        context 'and it was requested as json' do
          it 'succeeds and returns term data as json content type' do
            get :show, params: { id: '530369', vocab: 'OCLC_FAST', format: 'json' }
            expect(response).to be_successful
            expect(response.content_type).to eq 'application/json'
          end
        end

        context 'and it was requested as jsonld' do
          it 'succeeds and returns term data as jsonld content type' do
            get :show, params: { id: '530369', vocab: 'OCLC_FAST', format: 'jsonld' }
            expect(response).to be_successful
            expect(response.content_type).to eq 'application/ld+json'
            expect(JSON.parse(response.body).keys).to match_array ["@context", "@graph"]
          end
        end
      end

      context 'when cors headers are enabled' do
        before do
          Qa.config.enable_cors_headers
          stub_request(:get, 'http://id.worldcat.org/fast/530369')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'Access-Control-Allow-Origin is *' do
          get :show, params: { id: '530369', vocab: 'OCLC_FAST' }
          expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
        end
      end

      context 'when cors headers are disabled' do
        before do
          Qa.config.disable_cors_headers
          stub_request(:get, 'http://id.worldcat.org/fast/530369')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'Access-Control-Allow-Origin is not present' do
          get :show, params: { id: '530369', vocab: 'OCLC_FAST' }
          expect(response.headers.key?('Access-Control-Allow-Origin')).to be false
        end
      end
    end

    context 'in LOC authority' do
      context 'term found' do
        before do
          stub_request(:get, 'http://id.loc.gov/authorities/subjects/sh85118553')
            .to_return(status: 200, body: webmock_fixture('lod_loc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds and defaults to json content type' do
          get :show, params: { id: 'sh 85118553', vocab: 'LOC', subauthority: 'subjects' }
          expect(response).to be_successful
          expect(response.content_type).to eq 'application/json'
        end
      end
    end
  end

  describe '#fetch' do
    context 'producing internal server error' do
      context 'when server returns 500' do
        before do
          stub_request(:get, 'http://localhost/test_default/term?uri=http://id.worldcat.org/fast/530369').to_return(status: 500)
        end
        it 'returns 500' do
          expect(Rails.logger).to receive(:warn).with("Internal Server Error - Fetch term http://id.worldcat.org/fast/530369 unsuccessful for authority LOD_TERM_URI_PARAM_CONFIG")
          get :fetch, params: { vocab: 'LOD_TERM_URI_PARAM_CONFIG', uri: 'http://id.worldcat.org/fast/530369' }
          expect(response.code).to eq('500')
        end
      end

      context 'when rdf format error' do
        before do
          stub_request(:get, 'http://localhost/test_default/term?uri=http://id.worldcat.org/fast/530369').to_return(status: 200)
          allow(RDF::Graph).to receive(:load).and_raise(RDF::FormatError)
        end
        it 'returns 500' do
          msg = "RDF Format Error - Results from fetch term http://id.worldcat.org/fast/530369 for authority LOD_TERM_URI_PARAM_CONFIG was not identified as a valid RDF format.  " \
                "You may need to include the linkeddata gem."
          expect(Rails.logger).to receive(:warn).with(msg)
          get :fetch, params: { uri: 'http://id.worldcat.org/fast/530369', vocab: 'LOD_TERM_URI_PARAM_CONFIG' }
          expect(response.code).to eq('500')
        end
      end

      context "when error isn't specifically handled" do
        before do
          stub_request(:get, 'http://localhost/test_default/term?uri=http://id.worldcat.org/fast/530369').to_return(status: 501)
        end
        it 'returns 500' do
          expect(Rails.logger).to receive(:warn).with("Internal Server Error - Fetch term http://id.worldcat.org/fast/530369 unsuccessful for authority LOD_TERM_URI_PARAM_CONFIG")
          get :fetch, params: { uri: 'http://id.worldcat.org/fast/530369', vocab: 'LOD_TERM_URI_PARAM_CONFIG' }
          expect(response.code).to eq('500')
        end
      end
    end

    context 'when service unavailable' do
      before do
        stub_request(:get, 'http://localhost/test_default/term?uri=http://id.worldcat.org/fast/530369').to_return(status: 503)
      end
      it 'returns 503' do
        expect(Rails.logger).to receive(:warn).with("Service Unavailable - Fetch term http://id.worldcat.org/fast/530369 unsuccessful for authority LOD_TERM_URI_PARAM_CONFIG")
        get :fetch, params: { uri: 'http://id.worldcat.org/fast/530369', vocab: 'LOD_TERM_URI_PARAM_CONFIG' }
        expect(response.code).to eq('503')
      end
    end

    context 'when requested term is not found at the server' do
      before do
        stub_request(:get, 'http://localhost/test_default/term?uri=http://test.org/FAKE_ID').to_return(status: 404, body: '', headers: {})
      end
      it 'returns 404' do
        expect(Rails.logger).to receive(:warn).with('Term Not Found - Fetch term http://test.org/FAKE_ID unsuccessful for authority LOD_TERM_URI_PARAM_CONFIG')
        get :fetch, params: { uri: 'http://test.org/FAKE_ID', vocab: 'LOD_TERM_URI_PARAM_CONFIG' }
        expect(response.code).to eq('404')
      end
    end

    context 'in LOD_TERM_URI_PARAM_CONFIG authority' do
      context 'term found' do
        before do
          stub_request(:get, 'http://localhost/test_default/term?uri=http://id.worldcat.org/fast/530369')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end

        it 'succeeds and defaults to json content type' do
          get :fetch, params: { uri: 'http://id.worldcat.org/fast/530369', vocab: 'LOD_TERM_URI_PARAM_CONFIG' }
          expect(response).to be_successful
          expect(response.content_type).to eq 'application/json'
        end

        context 'and it was requested as json' do
          it 'succeeds and returns term data as json content type' do
            get :fetch, params: { uri: 'http://id.worldcat.org/fast/530369', vocab: 'LOD_TERM_URI_PARAM_CONFIG', format: 'json' }
            expect(response).to be_successful
            expect(response.content_type).to eq 'application/json'
          end
        end

        context 'and it was requested as jsonld' do
          it 'succeeds and returns term data as jsonld content type' do
            get :fetch, params: { uri: 'http://id.worldcat.org/fast/530369', vocab: 'LOD_TERM_URI_PARAM_CONFIG', format: 'jsonld' }
            expect(response).to be_successful
            expect(response.content_type).to eq 'application/ld+json'
            expect(JSON.parse(response.body).keys).to match_array ["@context", "@graph"]
          end
        end

        context 'blank nodes not included in predicates list' do
          before do
            stub_request(:get, 'http://localhost/test_default/term?uri=http://id.worldcat.org/fast/530369wbn')
              .to_return(status: 200, body: webmock_fixture('lod_term_with_blanknode_objects.nt'), headers: { 'Content-Type' => 'application/n-triples' })
          end
          it 'succeeds' do
            get :fetch, params: { uri: 'http://id.worldcat.org/fast/530369wbn', vocab: 'LOD_TERM_URI_PARAM_CONFIG' }
            expect(response).to be_successful
          end
        end
      end

      context 'when cors headers are enabled' do
        before do
          Qa.config.enable_cors_headers
          stub_request(:get, 'http://localhost/test_default/term?uri=http://id.worldcat.org/fast/530369')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'Access-Control-Allow-Origin is *' do
          get :fetch, params: { uri: 'http://id.worldcat.org/fast/530369', vocab: 'LOD_TERM_URI_PARAM_CONFIG' }
          expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
        end
      end

      context 'when cors headers are disabled' do
        before do
          Qa.config.disable_cors_headers
          stub_request(:get, 'http://localhost/test_default/term?uri=http://id.worldcat.org/fast/530369')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'Access-Control-Allow-Origin is not present' do
          get :fetch, params: { uri: 'http://id.worldcat.org/fast/530369', vocab: 'LOD_TERM_URI_PARAM_CONFIG' }
          expect(response.headers.key?('Access-Control-Allow-Origin')).to be false
        end
      end
    end
  end

  describe '#reload' do
    before do
      Qa.config.authorized_reload_token = 'A_TOKEN'
    end

    context 'when token does not match' do
      it 'returns 401' do
        get :reload, params: { auth_token: 'BAD_TOKEN' }
        expect(response.code).to eq('401')
      end
    end

    context 'when token does match' do
      it 'returns 200' do
        get :reload, params: { auth_token: 'A_TOKEN' }
        expect(response.code).to eq('200')
      end
    end
  end
end
