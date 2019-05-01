require 'spec_helper'

RSpec.describe Qa::Authorities::LinkedData::FindTerm do
  describe '#find' do
    let(:lod_oclc) { described_class.new(term_config(:OCLC_FAST)) }
    let(:lod_loc) { described_class.new(term_config(:LOC)) }

    context 'basic parameter testing' do
      context 'with bad id' do
        before do
          stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID')
            .to_return(status: 404, body: '', headers: {})
        end
        it 'raises a TermNotFound exception' do
          expect { lod_oclc.find('FAKE_ID') }.to raise_error Qa::TermNotFound, /.*\/FAKE_ID\ Not Found - Term may not exist at LOD Authority./
        end
      end
    end

    context 'in OCLC_FAST authority' do
      context 'term found' do
        let :results do
          stub_request(:get, 'http://id.worldcat.org/fast/530369')
            .to_return(status: 200, body: webmock_fixture('lod_oclc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
          lod_oclc.find('530369')
        end
        it 'has correct primary predicate values' do
          expect(results[:uri]).to eq('http://id.worldcat.org/fast/530369')
          expect(results[:id]).to eq('530369')
          expect(results[:label]).to eq ['Cornell University']
          expect(results[:altlabel]).to include('Ithaca (N.Y.). Cornell University', "Kornel\\xCA\\xB9skii universitet", "K\\xCA\\xBBang-nai-erh ta hs\\xC3\\xBCeh")
          expect(results[:altlabel].size).to eq 3
          expect(results[:sameas]).to include('http://id.loc.gov/authorities/names/n79021621', 'https://viaf.org/viaf/126293486')
        end

        it 'has correct number of predicates in pred-obj list' do
          expect(results['predicates'].count).to eq 7
        end

        it 'has primary predicates in pred-obj list' do
          expect(results['predicates']['http://purl.org/dc/terms/identifier']).to eq ['530369']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#prefLabel']).to eq ['Cornell University']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#altLabel'])
            .to include('Ithaca (N.Y.). Cornell University', "Kornel\\xCA\\xB9skii universitet",
                        "K\\xCA\\xBBang-nai-erh ta hs\\xC3\\xBCeh")
          expect(results['predicates']['http://schema.org/sameAs']).to include('http://id.loc.gov/authorities/names/n79021621', 'https://viaf.org/viaf/126293486')
        end

        it 'has unspecified predicate values' do
          expect(results['predicates']['http://www.w3.org/1999/02/22-rdf-syntax-ns#type']).to eq ['http://schema.org/Organization']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#inScheme'])
            .to include('http://id.worldcat.org/fast/ontology/1.0/#fast', 'http://id.worldcat.org/fast/ontology/1.0/#facet-Corporate')
          expect(results['predicates']['http://schema.org/name'])
            .to include('Cornell University', 'Ithaca (N.Y.). Cornell University', "Kornel\\xCA\\xB9skii universitet",
                        "K\\xCA\\xBBang-nai-erh ta hs\\xC3\\xBCeh")
        end
      end
    end

    context 'in LOC authority' do
      context 'term found' do
        let :results do
          stub_request(:get, 'http://id.loc.gov/authorities/subjects/sh85118553')
            .to_return(status: 200, body: webmock_fixture('lod_loc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
          lod_loc.find('sh 85118553', subauth: 'subjects')
        end
        it 'has correct primary predicate values' do
          expect(results[:uri]).to eq 'http://id.loc.gov/authorities/subjects/sh85118553'
          expect(results[:id]).to eq 'sh 85118553'
          expect(results[:label]).to eq ['Science']
          expect(results[:altlabel]).to include('Natural science', 'Science of science', 'Sciences')
        end

        it 'has correct number of predicates in pred-obj list' do
          expect(results['predicates'].count).to eq 14
        end

        it 'has primary predicates in pred-obj list' do
          expect(results['predicates']['http://id.loc.gov/vocabulary/identifiers/lccn']).to eq ['sh 85118553']
          expect(results['predicates']['http://www.loc.gov/mads/rdf/v1#authoritativeLabel']).to eq ['Science']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#prefLabel']).to eq ['Science']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#altLabel']).to include('Natural science', 'Science of science', 'Sciences')
        end

        it 'has loc mads predicate values' do
          expect(results['predicates']['http://www.loc.gov/mads/rdf/v1#classification']).to eq ['Q']
          expect(results['predicates']['http://www.loc.gov/mads/rdf/v1#isMemberOfMADSCollection'])
            .to include('http://id.loc.gov/authorities/subjects/collection_LCSHAuthorizedHeadings',
                        'http://id.loc.gov/authorities/subjects/collection_LCSH_General',
                        'http://id.loc.gov/authorities/subjects/collection_SubdivideGeographically')
          expect(results['predicates']['http://www.loc.gov/mads/rdf/v1#hasCloseExternalAuthority'])
            .to include('http://data.bnf.fr/ark:/12148/cb12321484k', 'http://data.bnf.fr/ark:/12148/cb119673416',
                        'http://data.bnf.fr/ark:/12148/cb119934236', 'http://data.bnf.fr/ark:/12148/cb12062047t',
                        'http://data.bnf.fr/ark:/12148/cb119469567', 'http://data.bnf.fr/ark:/12148/cb11933232c',
                        'http://data.bnf.fr/ark:/12148/cb122890536', 'http://data.bnf.fr/ark:/12148/cb121155321',
                        'http://data.bnf.fr/ark:/12148/cb15556043g', 'http://data.bnf.fr/ark:/12148/cb123662513',
                        'http://d-nb.info/gnd/4066562-8', 'http://data.bnf.fr/ark:/12148/cb120745812',
                        'http://data.bnf.fr/ark:/12148/cb11973101n', 'http://data.bnf.fr/ark:/12148/cb13328497r')
          expect(results['predicates']['http://www.loc.gov/mads/rdf/v1#isMemberOfMADSScheme'])
            .to eq ['http://id.loc.gov/authorities/subjects']
          expect(results['predicates']['http://www.loc.gov/mads/rdf/v1#editorialNote'])
            .to eq ['headings beginning with the word [Scientific;] and subdivision [Science] under ethnic groups and individual wars, e.g. [World War, 1939-1945--Science]']
        end

        it 'has more unspecified predicate values' do
          expect(results['predicates']['http://www.w3.org/1999/02/22-rdf-syntax-ns#type']).to include('http://www.loc.gov/mads/rdf/v1#Topic', 'http://www.loc.gov/mads/rdf/v1#Authority', 'http://www.w3.org/2004/02/skos/core#Concept')
          expect(results['predicates']['http://www.w3.org/2002/07/owl#sameAs']).to include('info:lc/authorities/sh85118553', 'http://id.loc.gov/authorities/sh85118553#concept')
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#closeMatch'])
            .to include('http://data.bnf.fr/ark:/12148/cb12321484k', 'http://data.bnf.fr/ark:/12148/cb119673416',
                        'http://data.bnf.fr/ark:/12148/cb119934236', 'http://data.bnf.fr/ark:/12148/cb12062047t',
                        'http://data.bnf.fr/ark:/12148/cb119469567', 'http://data.bnf.fr/ark:/12148/cb11933232c',
                        'http://data.bnf.fr/ark:/12148/cb122890536', 'http://data.bnf.fr/ark:/12148/cb121155321',
                        'http://data.bnf.fr/ark:/12148/cb15556043g', 'http://data.bnf.fr/ark:/12148/cb123662513',
                        'http://d-nb.info/gnd/4066562-8', 'http://data.bnf.fr/ark:/12148/cb120745812',
                        'http://data.bnf.fr/ark:/12148/cb11973101n', 'http://data.bnf.fr/ark:/12148/cb13328497r')
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#editorial'])
            .to eq ['headings beginning with the word [Scientific;] and subdivision [Science] under ethnic groups and individual wars, e.g. [World War, 1939-1945--Science]']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#inScheme']).to eq ['http://id.loc.gov/authorities/subjects']
        end
      end
    end

    # rubocop:disable RSpec/NestedGroups
    describe "language processing" do
      context "when filtering #find result" do
        context "and lang NOT passed in" do
          context "and NO language defined in authority config" do
            context "and NO language defined in Qa config" do
              let(:lod_lang_no_defaults) { described_class.new(term_config(:LOD_LANG_NO_DEFAULTS)) }
              let :results do
                stub_request(:get, "http://aims.fao.org/aos/agrovoc/c_9513")
                  .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
                lod_lang_no_defaults.find('http://aims.fao.org/aos/agrovoc/c_9513')
              end

              before do
                Qa.config.default_language = []
              end

              after do
                Qa.config.default_language = :en
              end

              it "is not filtered" do
                expect(results[:label]).to eq ['buttermilk', 'Babeurre']
                expect(results[:altlabel]).to eq ['yummy', 'délicieux']
                expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to include("buttermilk", "Babeurre")
                expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to include("yummy", "délicieux")
              end
            end
            context "and default_language is defined in Qa config" do
              let(:lod_lang_no_defaults) { described_class.new(term_config(:LOD_LANG_NO_DEFAULTS)) }
              let :results do
                stub_request(:get, "http://aims.fao.org/aos/agrovoc/c_9513")
                  .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
                lod_lang_no_defaults.find('http://aims.fao.org/aos/agrovoc/c_9513')
              end
              it "filters using Qa configured default for summary but not for predicates list" do
                expect(results[:label]).to eq ['buttermilk']
                expect(results[:altlabel]).to eq ['yummy']
                expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to include("buttermilk", "Babeurre")
                expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to include("yummy", "délicieux")
              end
            end
          end
          context "and language IS defined in authority config" do
            let(:lod_lang_defaults) { described_class.new(term_config(:LOD_LANG_DEFAULTS)) }
            let :results do
              stub_request(:get, "http://aims.fao.org/aos/agrovoc/c_9513")
                .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_defaults.find('http://aims.fao.org/aos/agrovoc/c_9513')
            end
            it "filters using authority configured language for summary but not for predicates list" do
              expect(results[:label]).to eq ['Babeurre']
              expect(results[:altlabel]).to eq ['délicieux']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to include("buttermilk", "Babeurre")
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to include("yummy", "délicieux")
            end
          end
          context "and multiple languages ARE defined in authority config" do
            let(:lod_lang_multi_defaults) { described_class.new(term_config(:LOD_LANG_MULTI_DEFAULTS)) }
            let :results do
              stub_request(:get, "http://aims.fao.org/aos/agrovoc/c_9513")
                .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfrde.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_multi_defaults.find('http://aims.fao.org/aos/agrovoc/c_9513')
            end
            it "filters using authority configured languages for summary but not for predicates list" do
              expect(results[:label]).to eq ['buttermilk', 'Babeurre']
              expect(results[:altlabel]).to eq ['yummy', 'délicieux']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to include("buttermilk", "Babeurre", "Buttermilch")
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to include("yummy", "délicieux", "lecker")
            end
          end
        end

        context "and lang IS passed in" do
          let(:lod_lang_defaults) { described_class.new(term_config(:LOD_LANG_DEFAULTS)) }
          let :results do
            stub_request(:get, "http://aims.fao.org/aos/agrovoc/c_9513")
              .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
            lod_lang_defaults.find('http://aims.fao.org/aos/agrovoc/c_9513', language: 'fr')
          end
          it "is filtered to specified language" do
            expect(results[:label]).to eq ['Babeurre']
            expect(results[:altlabel]).to eq ['délicieux']
            expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to include("buttermilk", "Babeurre")
            expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to include("yummy", "délicieux")
          end
        end

        context "and result does not have altlabel" do
          let(:lod_lang_defaults) { described_class.new(term_config(:LOD_LANG_DEFAULTS)) }
          let :results do
            stub_request(:get, "http://aims.fao.org/aos/agrovoc/c_9513")
              .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfr_noalt.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
            lod_lang_defaults.find('http://aims.fao.org/aos/agrovoc/c_9513', language: 'fr')
          end
          it "is filtered to specified language" do
            expect(results[:label]).to eq ['Babeurre']
            expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to include("buttermilk", "Babeurre")
          end
        end

        context "when replacement on authority term URL" do
          context "and using default" do
            let(:lod_lang_param) { described_class.new(term_config(:LOD_LANG_PARAM)) }
            let :results do
              stub_request(:get, "http://aims.fao.org/aos/agrovoc/c_9513?lang=en")
                .to_return(status: 200, body: webmock_fixture("lod_lang_term_en.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_param.find('http://aims.fao.org/aos/agrovoc/c_9513')
            end
            it "is correctly parsed" do
              expect(results[:label]).to eq ['buttermilk']
              expect(results[:altlabel]).to eq ['yummy']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to eq ['buttermilk']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to eq ['yummy']
            end
          end

          context "and lang specified" do
            let(:lod_lang_param) { described_class.new(term_config(:LOD_LANG_PARAM)) }
            let :results do
              stub_request(:get, "http://aims.fao.org/aos/agrovoc/c_9513?lang=fr")
                .to_return(status: 200, body: webmock_fixture("lod_lang_term_fr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_param.find('http://aims.fao.org/aos/agrovoc/c_9513', replacements: { 'lang' => 'fr' })
            end
            it "is correctly parsed" do
              expect(results[:label]).to eq ['Babeurre']
              expect(results[:altlabel]).to eq ['délicieux']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to eq ['Babeurre']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to eq ['délicieux']
            end
          end
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end

  def term_config(authority_name)
    Qa::Authorities::LinkedData::Config.new(authority_name).term
  end
end
