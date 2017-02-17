require 'spec_helper'

describe Qa::LinkedDataTermsController, type: :controller do
  before do
    @routes = Qa::Engine.routes
  end

  describe '#check_vocab_param' do
    it 'returns 404 if the vocabulary is missing' do
      get :search, params: { q: 'a query', vocab: '' }
      expect(response.code).to eq('404')
    end
  end

  describe '#check_query_param' do
    it 'returns 404 if the query is missing' do
      get :search, params: { q: '', vocab: 'OCLC' }
      expect(response.code).to eq('404')
    end
  end

  describe '#check_id_param' do
    it 'returns 404 if the id is missing' do
      get :show, params: { id: '', vocab: 'OCLC' }
      expect(response.code).to eq('404')
    end
  end

  describe '#init_authority' do
    context 'when the authority does not exist' do
      it 'returns 404' do
        expect(Rails.logger).to receive(:warn).with('Unable to initialize linked data authority NON-EXISTENT-AUTHORITY')
        get :search, params: { q: 'a query', vocab: 'non-existent-authority' }
        expect(response.code).to eq('404')
      end
    end
    context 'when a sub-authority does not exist' do
      it 'returns 404 if a sub-authority does not exist' do
        expect(Rails.logger).to receive(:warn).with('Unable to initialize linked data search sub-authority non-existent-subauthority for authority OCLC_FAST')
        get :search, params: { q: 'a query', vocab: 'OCLC_FAST', subauthority: 'non-existent-subauthority' }
        expect(response.code).to eq('404')
      end
    end
  end

  describe '#search' do
    context 'in OCLC_FAST authority' do
      context '0 search results' do
        before do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22supercalifragilisticexpialidocious%22&sortKeys=usage')
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
            .to_return(status: 200, body: webmock_fixture('lod_agrovoc_query_many_results.json'), headers: { 'Content-Type' => 'application/json' })
        end
        it 'succeeds' do
          get :search, params: { q: 'milk', vocab: 'AGROVOC' }
          expect(response).to be_success
        end
      end
    end
  end

  describe '#show' do
    context 'basic parameter testing' do
      context 'with bad id' do
        before do
          stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID/rdf.xml')
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
            .to_return(status: 404, body: '', headers:  {})
        end
        it 'returns 404' do
          expect(Rails.logger).to receive(:warn).with('Term Not Found - Fetch term FAKE_ID unsuccessful for authority OCLC_FAST')
          get :show, params: { id: 'FAKE_ID', vocab: 'OCLC_FAST' }
          expect(response.code).to eq('404')
        end
      end

      # context 'with language specified' do
      #   before do
      #     stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID/rdf.xml')
      #       .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
      #       .to_return(status: 404, body: '', headers:  {})
      #   end
      #   it 'raises a TermNotFound exception' do
      #     expect { lod_oclc.find('FAKE_ID', language: :en) }.to raise_error Qa::TermNotFound, /.*\/FAKE_ID\/rdf.xml Not Found - Term may not exist at LOD Authority./
      #   end
      # end
      #
      # context 'with replacements specified' do
      #   before do
      #     stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID/rdf.xml')
      #         .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
      #         .to_return(status: 404, body: '', headers:  {})
      #   end
      #   it 'raises a TermNotFound exception' do
      #     expect { lod_oclc.find('FAKE_ID') }.to raise_error Qa::TermNotFound, /.*\/FAKE_ID\/rdf.xml Not Found - Term may not exist at LOD Authority./
      #   end
      # end
      #
      # context 'with subauth specified' do
      #   before do
      #     stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID/rdf.xml')
      #         .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
      #         .to_return(status: 404, body: '', headers:  {})
      #   end
      #   it 'raises a TermNotFound exception' do
      #     expect { lod_oclc.find('FAKE_ID') }.to raise_error Qa::TermNotFound, /.*\/FAKE_ID\/rdf.xml Not Found - Term may not exist at LOD Authority./
      #   end
      # end
    end

    context 'in OCLC_FAST authority' do
      context 'term found' do
        before do
          stub_request(:get, 'http://id.worldcat.org/fast/530369/rdf.xml')
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
            .to_return(status: 200, body: webmock_fixture('lod_agrovoc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        end
        it 'succeeds' do
          get :show, params: { id: 'c_9513', vocab: 'AGROVOC' }
          expect(response).to be_success
        end
      end
    end

    context 'in LOC authority' do
      context 'term found' do
        before do
          stub_request(:get, 'http://id.loc.gov/authorities/subjects/sh85118553')
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
