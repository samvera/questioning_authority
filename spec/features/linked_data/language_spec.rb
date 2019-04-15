require 'spec_helper'
require 'qa/authorities/linked_data/config/search_config'
require 'json'

RSpec.describe 'language processing', type: :controller do # rubocop:disable RSpec/DescribeClass
  before do
    @controller = Qa::LinkedDataTermsController.new
    @routes = Qa::Engine.routes
    stub_request(:get, "http://localhost/test_default/search?query=my_query")
      .to_return(status: 200, body: webmock_fixture("lod_lang_search_enesfrde.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
  end

  let(:de_expected_results) do
    [
      { "uri" => "http://id.worldcat.org/fast/530369", "id" => "http://id.worldcat.org/fast/530369", "label" => "Buttermilch" }, # de only b/c all tagged
      { "uri" => "http://id.worldcat.org/fast/557490", "id" => "http://id.worldcat.org/fast/557490", "label" => "[Kondensmilch, lakto densigita]" }, # de + untagged
      { "uri" => "http://id.worldcat.org/fast/5140", "id" => "http://id.worldcat.org/fast/5140", "label" => "getrocknete Milch" } # de only b/c all tagged
    ]
  end
  let(:en_expected_results) do
    [
      { "uri" => "http://id.worldcat.org/fast/530369", "id" => "http://id.worldcat.org/fast/530369", "label" => "buttermilk" }, # en only b/c all tagged
      { "uri" => "http://id.worldcat.org/fast/557490", "id" => "http://id.worldcat.org/fast/557490", "label" => "[condensed milk, lakto densigita]" }, # en + untagged
      { "uri" => "http://id.worldcat.org/fast/5140", "id" => "http://id.worldcat.org/fast/5140", "label" => "dried milk" } # en only b/c all tagged
    ]
  end
  let(:es_expected_results) do
    [
      { "uri" => "http://id.worldcat.org/fast/530369", "id" => "http://id.worldcat.org/fast/530369", "label" => "[Buttermilch, buttermilk, Babeurre]" }, # all matches b/c no matching tag
      { "uri" => "http://id.worldcat.org/fast/557490", "id" => "http://id.worldcat.org/fast/557490", "label" => "[leche condensada, lakto densigita]" }, # es + untagged
      { "uri" => "http://id.worldcat.org/fast/5140", "id" => "http://id.worldcat.org/fast/5140", "label" => "leche en polvo" } # es only b/c all tagged
    ]
  end
  let(:fr_expected_results) do
    [
      { "uri" => "http://id.worldcat.org/fast/530369", "id" => "http://id.worldcat.org/fast/530369", "label" => "Babeurre" }, # fr only b/c all tagged
      { "uri" => "http://id.worldcat.org/fast/557490", "id" => "http://id.worldcat.org/fast/557490", "label" => "[lait condensé, lakto densigita]" }, # fr + untagged
      { "uri" => "http://id.worldcat.org/fast/5140", "id" => "http://id.worldcat.org/fast/5140", "label" => "lait en poudre" } # fr only b/c all tagged
    ]
  end
  let(:fr_alt_expected_results) do
    [
      { "uri" => "http://id.worldcat.org/fast/530369", "id" => "530369", "label" => "Babeurre (délicieux)" }, # fr only in results + (alt label)
      { "uri" => "http://id.worldcat.org/fast/557490", "id" => "557490", "label" => "lait condensé (crémeux)" }, # fr only in results + (alt label)
      { "uri" => "http://id.worldcat.org/fast/5140", "id" => "5140", "label" => "lait en poudre (poudreux)" } # fr only in results + (alt label)
    ]
  end
  let(:sv_alt_expected_results) do
    [
      { "uri" => "http://id.worldcat.org/fast/530369", "id" => "530369", "label" => "kärnmjölk (smaskigt)" }, # sv only in results + (alt label)
      { "uri" => "http://id.worldcat.org/fast/557490", "id" => "557490", "label" => "kondenserad mjölk (krämig)" }, # sv only in results + (alt label)
      { "uri" => "http://id.worldcat.org/fast/5140", "id" => "5140", "label" => "mjölkpulver (pulver-)" } # sv only in results + (alt label)
    ]
  end
  let(:nil_expected_results) do
    # returns values for all language when requested lang is nil
    [
      { "uri" => "http://id.worldcat.org/fast/530369", "id" => "http://id.worldcat.org/fast/530369", "label" => "[Buttermilch, buttermilk, Babeurre]" },
      { "uri" => "http://id.worldcat.org/fast/557490", "id" => "http://id.worldcat.org/fast/557490", "label" => "[Kondensmilch, condensed milk, leche condensada, lait condensé, lakto densigita]" },
      { "uri" => "http://id.worldcat.org/fast/5140", "id" => "http://id.worldcat.org/fast/5140", "label" => "[getrocknete Milch, dried milk, leche en polvo, lait en poudre]" }
    ]
  end

  context 'when configured authority URL includes a language parameter' do
    before do
      stub_request(:get, "http://localhost/test_default/search?lang=sv&param1=delta&param2=echo&query=my_query&subauth=search_sub1_name")
        .to_return(status: 200, body: webmock_fixture("lod_lang_search_sv.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
    end

    it 'passes language to authority for filtering based on user specified language' do
      get :search, params: { q: 'my_query', vocab: 'LOD_FULL_CONFIG', maximumRecords: '3', lang: 'sv' }
      expect(response).to be_successful
      results = JSON.parse(response.body)
      expect(results).to match_array sv_alt_expected_results
    end
  end

  context 'when language includes a WILDCARD (i.e. *)' do
    before do
      stub_request(:get, "http://localhost/test_default/search?subauth=search_sub1_name&query=my_query&param1=delta&param2=echo&lang=fr")
        .to_return(status: 200, body: webmock_fixture("lod_lang_search_fr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
    end

    it 'does not filter languages through graph service' do
      get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3', lang: '*' }
      expect(response).to be_successful
      results = JSON.parse(response.body)
      expect(results).to match_array nil_expected_results
    end

    it 'reverts to parameter default when passing to the authority' do
      get :search, params: { q: 'my_query', vocab: 'LOD_FULL_CONFIG', maximumRecords: '3', lang: '*' }
      expect(response).to be_successful
      results = JSON.parse(response.body)
      expect(results).to match_array fr_alt_expected_results
    end
  end

  context 'when site defined default language' do
    before do
      allow(Qa.config).to receive(:default_language).and_return('en')
    end

    context 'and authority defined default language' do
      before do
        allow_any_instance_of(Qa::Authorities::LinkedData::SearchConfig).to receive(:language).and_return('de') # rubocop:disable RSpec/AnyInstance
      end

      context 'and language is passed via access_language in the http request header' do
        context 'and user passes language as parameter' do
          it 'filters results to the user passed in language (e.g. es + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3', lang: 'es' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array es_expected_results
          end
        end

        context 'and user does NOT pass in language as a parameter' do
          it 'filters results to the http request access_language (e.g. fr + untagged)' do
            request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr'
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array fr_expected_results
          end
        end
      end

      context 'and language is NOT passed via access_language in the http request header' do
        context 'and user passes language as parameter' do
          it 'filters results to the user passed in language (e.g. es + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3', lang: 'es' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array es_expected_results
          end
        end

        context 'and user does NOT pass in language as a parameter' do
          it 'filters results to the authority defined language (e.g. de + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array de_expected_results
          end
        end
      end
    end

    context 'and authority does NOT define default language' do
      before do
        allow_any_instance_of(Qa::Authorities::LinkedData::SearchConfig).to receive(:language).and_return(nil) # rubocop:disable RSpec/AnyInstance
      end

      context 'and language is passed via access_language in the http request header' do
        context 'and user passes language as parameter' do
          it 'filters results to the user passed in language (e.g. es + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3', lang: 'es' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array es_expected_results
          end
        end

        context 'and user does NOT pass in language as a parameter' do
          it 'filters results to the http request access_language (e.g. fr + untagged)' do
            request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr'
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array fr_expected_results
          end
        end
      end

      context 'and language is NOT passed via access_language in the http request header' do
        context 'and user passes language as parameter' do
          it 'filters results to the user passed in language (e.g. es + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3', lang: 'es' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array es_expected_results
          end
        end

        context 'and user does NOT pass in language as a parameter' do
          it 'filters results to the site defined language (e.g. en + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array en_expected_results
          end
        end
      end
    end
  end

  context 'when site does NOT define default language' do
    before do
      allow(Qa.config).to receive(:default_language).and_return(nil)
    end

    context 'and authority defined default language' do
      before do
        allow_any_instance_of(Qa::Authorities::LinkedData::SearchConfig).to receive(:language).and_return('de') # rubocop:disable RSpec/AnyInstance
      end

      context 'and language is passed via access_language in the http request header' do
        context 'and user passes language as parameter' do
          it 'filters results to the user passed in language (e.g. es + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3', lang: 'es' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array es_expected_results
          end
        end

        context 'and user does NOT pass in language as a parameter' do
          it 'filters results to the http request access_language (e.g. fr + untagged)' do
            request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr'
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array fr_expected_results
          end
        end
      end

      context 'and language is NOT passed via access_language in the http request header' do
        context 'and user passes language as parameter' do
          it 'filters results to the user passed in language (e.g. es + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3', lang: 'es' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array es_expected_results
          end
        end

        context 'and user does NOT pass in language as a parameter' do
          it 'filters results to the authority defined language (e.g. de + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array de_expected_results
          end
        end
      end
    end

    context 'and authority does NOT define default language' do
      before do
        allow_any_instance_of(Qa::Authorities::LinkedData::SearchConfig).to receive(:language).and_return(nil) # rubocop:disable RSpec/AnyInstance
      end

      context 'and language is passed via access_language in the http request header' do
        context 'and user passes language as parameter' do
          it 'filters results to the user passed in language (e.g. es + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3', lang: 'es' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array es_expected_results
          end
        end

        context 'and user does NOT pass in language as a parameter' do
          it 'filters results to the http request access_language (e.g. fr + untagged)' do
            request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr'
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array fr_expected_results
          end
        end
      end

      context 'and language is NOT passed via access_language in the http request header' do
        context 'and user passes language as parameter' do
          it 'filters results to the user passed in language (e.g. es + untagged)' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3', lang: 'es' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array es_expected_results
          end
        end

        context 'and user does NOT pass in language as a parameter' do
          it 'does not filter results' do
            get :search, params: { q: 'my_query', vocab: 'LOD_MIN_CONFIG', maximumRecords: '3' }
            expect(response).to be_successful
            results = JSON.parse(response.body)
            expect(results).to match_array nil_expected_results
          end
        end
      end
    end
  end
end
