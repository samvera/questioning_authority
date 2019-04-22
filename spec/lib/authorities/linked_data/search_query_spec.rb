require 'spec_helper'

RSpec.describe Qa::Authorities::LinkedData::SearchQuery do
  describe '#search' do
    let(:lod_oclc) { described_class.new(search_config(:OCLC_FAST)) }

    context 'in OCLC_FAST authority' do
      context '0 search results' do
        let :results do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22supercalifragilisticexpialidocious%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_query_no_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
          lod_oclc.search('supercalifragilisticexpialidocious', replacements: { 'maximumRecords' => '3' })
        end
        it 'returns an empty array' do
          expect(results).to eq([])
        end
      end

      context '3 search results' do
        let :results do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_all_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
          lod_oclc.search('cornell', replacements: { 'maximumRecords' => '3' })
        end
        it 'is correctly parsed' do
          expect(results.count).to eq(3)
          expect(results.first).to eq(uri: 'http://id.worldcat.org/fast/530369', id: '530369', label: 'Cornell University')
          expect(results.second).to eq(uri: 'http://id.worldcat.org/fast/5140', id: '5140', label: 'Cornell, Joseph')
          expect(results.third).to eq(uri: 'http://id.worldcat.org/fast/557490', id: '557490', label: 'New York State School of Industrial and Labor Relations')
        end
      end
    end

    context 'in OCLC_FAST authority and personal_name subauthority' do
      context '0 search results' do
        let :results do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=oclc.personalName%20all%20%22supercalifragilisticexpialidocious%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_query_no_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
          lod_oclc.search('supercalifragilisticexpialidocious', subauth: 'personal_name', replacements: { 'maximumRecords' => '3' })
        end
        it 'returns an empty array' do
          expect(results).to eq([])
        end
      end

      context '3 search results' do
        let :results do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=oclc.personalName%20all%20%22cornell%22&sortKeys=usage')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_personalName_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
          lod_oclc.search('cornell', subauth: 'personal_name', replacements: { 'maximumRecords' => '3' })
        end
        it 'is correctly parsed' do
          expect(results.count).to eq(3)
          expect(results.first).to eq(uri: 'http://id.worldcat.org/fast/409667', id: '409667', label: 'Cornell, Ezra, 1807-1874')
          expect(results.second).to eq(uri: 'http://id.worldcat.org/fast/5140', id: '5140', label: 'Cornell, Joseph')
          expect(results.third).to eq(uri: 'http://id.worldcat.org/fast/72456', id: '72456', label: 'Cornell, Sarah Maria, 1802-1832')
        end
      end
    end

    context 'when id predicate is not specified' do
      let(:min_authority) { described_class.new(search_config(:LOD_MIN_CONFIG)) }
      let :results do
        stub_request(:get, 'http://localhost/test_default/search?query=peanuts')
          .to_return(status: 200, body: webmock_fixture('lod_oclc_personalName_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
        min_authority.search('peanuts')
      end
      it 'uses subject uri for id' do
        expect(results.count).to eq(3)
        expect(results.first).to eq(uri: 'http://id.worldcat.org/fast/409667', id: 'http://id.worldcat.org/fast/409667', label: 'Cornell, Ezra, 1807-1874')
        expect(results.second).to eq(uri: 'http://id.worldcat.org/fast/5140', id: 'http://id.worldcat.org/fast/5140', label: 'Cornell, Joseph')
        expect(results.third).to eq(uri: 'http://id.worldcat.org/fast/72456', id: 'http://id.worldcat.org/fast/72456', label: 'Cornell, Sarah Maria, 1802-1832')
      end
    end

    # context 'in LOC authority' do
    #   ###################################
    #   ### SEARCH NOT SUPPORTED BY LOC ###
    #   ###################################
    #   # let(:lod_loc) { described_class.new(search_config(:LOC)) }
    # end

    # rubocop:disable RSpec/NestedGroups
    describe "language processing" do
      context "when filtering #search results" do
        context "and lang NOT passed in" do
          context "and NO language defined in authority config" do
            context "and NO language defined in Qa config" do
              let(:lod_lang_no_defaults) { described_class.new(search_config(:LOD_LANG_NO_DEFAULTS)) }
              let :results do
                stub_request(:get, "http://localhost/test_no_default/search?query=milk")
                  .to_return(status: 200, body: webmock_fixture("lod_lang_search_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
                lod_lang_no_defaults.search('milk')
              end

              before do
                Qa.config.default_language = []
              end

              after do
                Qa.config.default_language = :en
              end

              it "is not filtered" do
                expect(results.first[:label]).to eq('[buttermilk, Babeurre] (yummy, délicieux)')
                expect(results.second[:label]).to eq('[condensed milk, lait condensé] (creamy, crémeux)')
                expect(results.third[:label]).to eq('[dried milk, lait en poudre] (powdery, poudreux)')
              end
            end

            context "and default_language is defined in Qa config" do
              let(:lod_lang_no_defaults) { described_class.new(search_config(:LOD_LANG_NO_DEFAULTS)) }
              let :results do
                stub_request(:get, "http://localhost/test_no_default/search?query=milk")
                  .to_return(status: 200, body: webmock_fixture("lod_lang_search_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
                lod_lang_no_defaults.search('milk')
              end
              it "filters using Qa configured default" do
                expect(results.first[:label]).to eq('buttermilk (yummy)')
                expect(results.second[:label]).to eq('condensed milk (creamy)')
                expect(results.third[:label]).to eq('dried milk (powdery)')
              end
            end
          end

          context "and language IS defined in authority config" do
            let(:lod_lang_defaults) { described_class.new(search_config(:LOD_LANG_DEFAULTS)) }
            let :results do
              stub_request(:get, "http://localhost/test_default/search?query=milk")
                .to_return(status: 200, body: webmock_fixture("lod_lang_search_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_defaults.search('milk')
            end
            it "is filtered to authority defined language" do
              expect(results.first[:label]).to eq('Babeurre (délicieux)')
              expect(results.second[:label]).to eq('lait condensé (crémeux)')
              expect(results.third[:label]).to eq('lait en poudre (poudreux)')
            end
          end
        end

        context "and multiple languages ARE defined in authority config" do
          let(:lod_lang_multi_defaults) { described_class.new(search_config(:LOD_LANG_MULTI_DEFAULTS)) }
          let :results do
            stub_request(:get, "http://localhost/test_default/search?query=milk")
              .to_return(status: 200, body: webmock_fixture("lod_lang_search_enfrde.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
            lod_lang_multi_defaults.search('milk')
          end
          it "is filtered to authority defined languages" do
            expect(results.first[:label]).to eq('[buttermilk, Babeurre] (yummy, délicieux)')
            expect(results.second[:label]).to eq('[condensed milk, lait condensé] (creamy, crémeux)')
            expect(results.third[:label]).to eq('[dried milk, lait en poudre] (powdery, poudreux)')
          end
        end

        context "and language IS passed in to search" do
          let(:lod_lang_defaults) { described_class.new(search_config(:LOD_LANG_DEFAULTS)) }
          let :results do
            stub_request(:get, "http://localhost/test_default/search?query=milk")
              .to_return(status: 200, body: webmock_fixture("lod_lang_search_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
            lod_lang_defaults.search('milk', language: :fr)
          end
          it "is filtered to specified language" do
            expect(results.first[:label]).to eq('Babeurre (délicieux)')
            expect(results.second[:label]).to eq('lait condensé (crémeux)')
            expect(results.third[:label]).to eq('lait en poudre (poudreux)')
          end
        end

        context "when replacement on authority search URL" do
          context "and using default" do
            let(:lod_lang_param) { described_class.new(search_config(:LOD_LANG_PARAM)) }
            let :results do
              stub_request(:get, "http://localhost/test_replacement/search?lang=en&query=milk")
                .to_return(status: 200, body: webmock_fixture("lod_lang_search_en.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_param.search("milk")
            end
            it "is correctly parsed" do
              expect(results.first[:label]).to eq('buttermilk (yummy)')
              expect(results.second[:label]).to eq('condensed milk (creamy)')
              expect(results.third[:label]).to eq('dried milk (powdery)')
            end
          end

          context "and lang specified" do
            let(:lod_lang_param) { described_class.new(search_config(:LOD_LANG_PARAM)) }
            let :results do
              stub_request(:get, "http://localhost/test_replacement/search?query=milk&lang=fr")
                .to_return(status: 200, body: webmock_fixture("lod_lang_search_fr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_param.search("milk", replacements: { 'lang' => 'fr' })
            end
            it "is correctly parsed" do
              expect(results.first[:label]).to eq('Babeurre (délicieux)')
              expect(results.second[:label]).to eq('lait condensé (crémeux)')
              expect(results.third[:label]).to eq('lait en poudre (poudreux)')
            end
          end
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end

  def search_config(authority_name)
    Qa::Authorities::LinkedData::Config.new(authority_name).search
  end
end
