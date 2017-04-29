require 'spec_helper'

describe Qa::LinkedDataTermsController, type: :controller do
  before do
    @routes = Qa::Engine.routes
  end

  describe '#check_authority' do
    it 'returns 404 if the vocabulary is not specified' do
      expect(Rails.logger).to receive(:warn).with("Required param 'vocab' is missing or empty")
      get :search, params: { q: 'a query', vocab: '' }
      expect(response.code).to eq('404')
    end

    it 'returns 404 if the vocabulary is not specified' do
      expect(Rails.logger).to receive(:warn).with("Required param 'vocab' is missing or empty")
      get :show, params: { id: 'C_1234', vocab: '' }
      expect(response.code).to eq('404')
    end
  end

  describe '#check_search_subauthority' do
    it 'returns 404 if the query subauthority is missing' do
      expect(Rails.logger).to receive(:warn).with("Unable to initialize linked data search sub-authority '' for authority 'OCLC_FAST'")
      get :search, params: { q: 'test', vocab: 'OCLC_FAST', subauthority: '' }
      expect(response.code).to eq('404')
    end
    it 'returns 404 if the query subauthority is invalid' do
      expect(Rails.logger).to receive(:warn).with("Unable to initialize linked data search sub-authority 'FAKE_SUBAUTHORITY' for authority 'OCLC_FAST'")
      get :search, params: { vocab: 'OCLC_FAST', subauthority: 'FAKE_SUBAUTHORITY' }
      expect(response.code).to eq('404')
    end
  end

  describe '#check_show_subauthority' do
    it 'returns 404 if the show subauthority is missing' do
      expect(Rails.logger).to receive(:warn).with("Unable to initialize linked data term sub-authority '' for authority 'OCLC_FAST'")
      get :show, params: { id: 'C_123', vocab: 'OCLC_FAST', subauthority: '' }
      expect(response.code).to eq('404')
    end
    it 'returns 404 if the show subauthority is invalid' do
      expect(Rails.logger).to receive(:warn).with("Unable to initialize linked data term sub-authority 'FAKE_SUBAUTHORITY' for authority 'OCLC_FAST'")
      get :show, params: { id: 'C_123', vocab: 'OCLC_FAST', subauthority: 'FAKE_SUBAUTHORITY' }
      expect(response.code).to eq('404')
    end
  end

  describe '#check_query_param' do
    it 'returns 404 if the query is missing' do
      expect(Rails.logger).to receive(:warn).with("Required search param 'q' is missing or empty")
      get :search, params: { vocab: 'OCLC_FAST' }
      expect(response.code).to eq('404')
    end
  end

  describe '#check_id_param' do
    it 'returns 404 if the id is missing' do
      expect(Rails.logger).to receive(:warn).with("Required show param 'id' is missing or empty")
      get :show, params: { id: '', vocab: 'OCLC_FAST' }
      expect(response.code).to eq('404')
    end
  end

  describe '#init_authority' do
    context 'when the authority does not exist' do
      it 'returns 404' do
        expect(Rails.logger).to receive(:warn).with("Unable to initialize linked data authority 'FAKE_AUTHORITY'")
        get :search, params: { q: 'a query', vocab: 'fake_authority' }
        expect(response.code).to eq('404')
      end
    end
  end

  describe '#search' do
    context 'in OCLC_FAST authority' do
      context '0 search results' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22supercalifragilisticexpialidocious%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_query_no_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :search, params: { q: 'supercalifragilisticexpialidocious', vocab: 'OCLC_FAST', maximumRecords: '3' }
          expect(response).to be_success
        end
      end

      context '3 search results' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_all_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :search, params: { q: 'cornell', vocab: 'OCLC_FAST', maximumRecords: '3' }
          expect(response).to be_success
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
          expect(response).to be_success
        end
      end

      context '3 search results' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=oclc.personalName%20all%20%22cornell%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_personalName_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :search, params: { q: 'cornell', vocab: 'OCLC_FAST', subauthority: 'personal_name', maximumRecords: '3' }
          expect(response).to be_success
        end
      end
    end

    context 'in AGROVOC authority' do
      context '0 search results' do
        before do
          stub_request(:get, 'http://aims.fao.org/skosmos/rest/v1/search/?lang=en&query=*supercalifragilisticexpialidocious*')
            .to_return(status: 200, body: webmock_fixture('lod_agrovoc_query_no_results.json'), headers: { 'Content-Type' => 'application/json' })
        end
        it 'succeeds' do
          get :search, params: { q: 'supercalifragilisticexpialidocious', vocab: 'AGROVOC' }
          expect(response).to be_success
        end
      end

      context '3 search results' do
        before do
          stub_request(:get, 'http://aims.fao.org/skosmos/rest/v1/search/?lang=en&query=*milk*')
            .to_return(status: 200, body: webmock_fixture('lod_agrovoc_query_many_results.json'), headers: { 'Content-Type' => 'application/json' })
        end
        it 'succeeds' do
          get :search, params: { q: 'milk', vocab: 'AGROVOC' }
          expect(response).to be_success
        end
      end
    end

    context 'in GEONAMES authority' do
      context '0 search results' do
        before do
          stub_request(:get, 'http://api.geonames.org/search?q=supercalifragilisticexpialidocious&maxRows=10&username=demo&type=rdf')
            .to_return(status: 200, body: webmock_fixture('lod_geonames_query_no_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :search, params: { q: 'supercalifragilisticexpialidocious', vocab: 'GEONAMES' }
          expect(response).to be_success
        end
      end

      context '4 search results' do
        before do
          stub_request(:get, 'http://api.geonames.org/search?q=ithaca&maxRows=10&username=demo&type=rdf')
            .to_return(status: 200, body: webmock_fixture('lod_geonames_query_many_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :search, params: { q: 'ithaca', vocab: 'GEONAMES' }
          expect(response).to be_success
        end
      end
    end
  end

  describe '#show' do
    context 'basic parameter testing' do
      context 'with bad id' do
        before do
          stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID')
            .to_return(status: 404, body: '', headers:  {})
        end
        it 'returns 404' do
          expect(Rails.logger).to receive(:warn).with('Term Not Found - Fetch term FAKE_ID unsuccessful for authority OCLC_FAST')
          get :show, params: { id: 'FAKE_ID', vocab: 'OCLC_FAST' }
          expect(response.code).to eq('404')
        end
      end
    end

    context 'in OCLC_FAST authority' do
      context 'term found' do
        before do
          stub_request(:get, 'http://id.worldcat.org/fast/530369')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :show, params: { id: '530369', vocab: 'OCLC_FAST' }
          expect(response).to be_success
        end
      end
    end

    context 'in AGROVOC authority' do
      context 'term found' do
        before do
          stub_request(:get, 'http://aims.fao.org/skosmos/rest/v1/data?uri=http://aims.fao.org/aos/agrovoc/c_9513')
            .to_return(status: 200, body: webmock_fixture('lod_agrovoc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :show, params: { id: 'c_9513', vocab: 'AGROVOC' }
          expect(response).to be_success
        end
      end
    end

    context 'in GEONAMES authority' do
      context 'term found' do
        before do
          stub_request(:get, 'http://sws.geonames.org/5122432/')
            .to_return(status: 200, body: webmock_fixture('lod_geonames_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :show, params: { id: 'http://sws.geonames.org/5122432/', vocab: 'GEONAMES' }
          expect(response).to be_success
        end
      end
    end

    context 'in LOC authority' do
      context 'term found' do
        before do
          stub_request(:get, 'http://id.loc.gov/authorities/subjects/sh85118553')
            .to_return(status: 200, body: webmock_fixture('lod_loc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :show, params: { id: 'sh85118553', vocab: 'LOC', subauthority: 'subjects' }
          expect(response).to be_success
        end
      end
    end
  end
end
