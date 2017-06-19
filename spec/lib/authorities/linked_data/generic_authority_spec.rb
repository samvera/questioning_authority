require 'spec_helper'

RSpec.describe Qa::Authorities::LinkedData::GenericAuthority do
  describe '#search' do
    let(:lod_oclc) { described_class.new(:OCLC_FAST) }
    let(:lod_agrovoc) { described_class.new(:AGROVOC) }

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

    context 'in AGROVOC authority' do
      context '0 search results' do
        let :results do
          stub_request(:get, 'http://artemide.art.uniroma2.it:8081/agrovoc/rest/v1/search/?lang=en&query=*supercalifragilisticexpialidocious*')
            .to_return(status: 200, body: webmock_fixture('lod_agrovoc_query_no_results.json'), headers: { 'Content-Type' => 'application/json' })
          lod_agrovoc.search('supercalifragilisticexpialidocious')
        end
        it 'returns an empty array' do
          expect(results).to eq([])
        end
      end

      context '3 search results' do
        let :results do
          stub_request(:get, 'http://artemide.art.uniroma2.it:8081/agrovoc/rest/v1/search/?lang=en&query=*milk*')
            .to_return(status: 200, body: webmock_fixture('lod_agrovoc_query_many_results.json'), headers: { 'Content-Type' => 'application/json' })
          lod_agrovoc.search('milk')
        end
        it 'is correctly parsed' do
          expect(results.count).to eq(64)
          expect(results.first).to eq(uri: 'http://aims.fao.org/aos/agrovoc/c_8602', id: 'http://aims.fao.org/aos/agrovoc/c_8602', label: 'acidophilus milk')
          expect(results.second).to eq(uri: 'http://aims.fao.org/aos/agrovoc/c_16076', id: 'http://aims.fao.org/aos/agrovoc/c_16076', label: 'buffalo milk')
          expect(results.third).to eq(uri: 'http://aims.fao.org/aos/agrovoc/c_9513', id: 'http://aims.fao.org/aos/agrovoc/c_9513', label: 'buttermilk')
        end
      end
    end

    # context 'in LOC authority' do
    #   ###################################
    #   ### SEARCH NOT SUPPORTED BY LOC ###
    #   ###################################
    #   # let(:lod_loc) { Qa::Authorities::LinkedData::GenericAuthority.new(:LOC) }
    # end

    describe "language processing" do
      context "when filtering #search results" do
        context "and lang NOT passed in" do
          context "and NO default defined in config" do
            let(:lod_lang_no_defaults) { described_class.new(:LOD_LANG_NO_DEFAULTS) }
            let :results do
              stub_request(:get, "http://localhost/test_no_default/search?query=milk")
                .to_return(status: 200, body: webmock_fixture("lod_lang_search_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_no_defaults.search('milk')
            end
            it "is not filtered" do
              expect(results.first[:label]).to eq('[buttermilk, Babeurre] (yummy, délicieux)')
              expect(results.second[:label]).to eq('[condensed milk, lait condensé] (creamy, crémeux)')
              expect(results.third[:label]).to eq('[dried milk, lait en poudre] (powdery, poudreux)')
            end
          end

          context "and default IS defined in config" do
            let(:lod_lang_defaults) { described_class.new(:LOD_LANG_DEFAULTS) }
            let :results do
              stub_request(:get, "http://localhost/test_default/search?query=milk")
                .to_return(status: 200, body: webmock_fixture("lod_lang_search_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_defaults.search('milk')
            end
            it "is filtered to default" do
              expect(results.first[:label]).to eq('buttermilk (yummy)')
              expect(results.second[:label]).to eq('condensed milk (creamy)')
              expect(results.third[:label]).to eq('dried milk (powdery)')
            end
          end
        end

        context "and multiple defaults ARE defined in config" do
          let(:lod_lang_multi_defaults) { described_class.new(:LOD_LANG_MULTI_DEFAULTS) }
          let :results do
            stub_request(:get, "http://localhost/test_default/search?query=milk")
              .to_return(status: 200, body: webmock_fixture("lod_lang_search_enfrde.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
            lod_lang_multi_defaults.search('milk')
          end
          it "is filtered to default" do
            expect(results.first[:label]).to eq('[buttermilk, Babeurre] (yummy, délicieux)')
            expect(results.second[:label]).to eq('[condensed milk, lait condensé] (creamy, crémeux)')
            expect(results.third[:label]).to eq('[dried milk, lait en poudre] (powdery, poudreux)')
          end
        end

        context "and lang IS passed in" do
          let(:lod_lang_defaults) { described_class.new(:LOD_LANG_DEFAULTS) }
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
            let(:lod_lang_param) { described_class.new(:LOD_LANG_PARAM) }
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
            let(:lod_lang_param) { described_class.new(:LOD_LANG_PARAM) }
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
  end

  describe '#find' do
    let(:lod_oclc) { described_class.new(:OCLC_FAST) }
    let(:lod_agrovoc) { described_class.new(:AGROVOC) }
    let(:lod_loc) { described_class.new(:LOC) }

    context 'basic parameter testing' do
      context 'with bad id' do
        before do
          stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID')
            .to_return(status: 404, body: '', headers:  {})
        end
        it 'raises a TermNotFound exception' do
          expect { lod_oclc.find('FAKE_ID') }.to raise_error Qa::TermNotFound, /.*\/FAKE_ID\ Not Found - Term may not exist at LOD Authority./
        end
      end

      # context 'with language specified' do
      #   before do
      #     stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID')
      #       .to_return(status: 404, body: '', headers:  {})
      #   end
      #   it 'raises a TermNotFound exception' do
      #     expect { lod_oclc.find('FAKE_ID', language: :en) }.to raise_error Qa::TermNotFound, /.*\/FAKE_ID\ Not Found - Term may not exist at LOD Authority./
      #   end
      # end
      #
      # context 'with replacements specified' do
      #   before do
      #     stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID')
      #       .to_return(status: 404, body: '', headers:  {})
      #   end
      #   it 'raises a TermNotFound exception' do
      #     expect { lod_oclc.find('FAKE_ID') }.to raise_error Qa::TermNotFound, /.*\/FAKE_ID\ Not Found - Term may not exist at LOD Authority./
      #   end
      # end
      #
      # context 'with subauth specified' do
      #   before do
      #     stub_request(:get, 'http://id.worldcat.org/fast/FAKE_ID')
      #       .to_return(status: 404, body: '', headers:  {})
      #   end
      #   it 'raises a TermNotFound exception' do
      #     expect { lod_oclc.find('FAKE_ID') }.to raise_error Qa::TermNotFound, /.*\/FAKE_ID\ Not Found - Term may not exist at LOD Authority./
      #   end
      # end
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
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#altLabel']).to include('Ithaca (N.Y.). Cornell University', "Kornel\\xCA\\xB9skii universitet", "K\\xCA\\xBBang-nai-erh ta hs\\xC3\\xBCeh")
          expect(results['predicates']['http://schema.org/sameAs']).to include('http://id.loc.gov/authorities/names/n79021621', 'https://viaf.org/viaf/126293486')
        end

        it 'has unspecified predicate values' do
          expect(results['predicates']['http://www.w3.org/1999/02/22-rdf-syntax-ns#type']).to eq ['http://schema.org/Organization']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#inScheme']).to include('http://id.worldcat.org/fast/ontology/1.0/#fast', 'http://id.worldcat.org/fast/ontology/1.0/#facet-Corporate')
          expect(results['predicates']['http://schema.org/name']).to include('Cornell University', 'Ithaca (N.Y.). Cornell University', "Kornel\\xCA\\xB9skii universitet", "K\\xCA\\xBBang-nai-erh ta hs\\xC3\\xBCeh")
        end
      end
    end

    context 'in AGROVOC authority' do
      context 'term found' do
        let :results do
          stub_request(:get, 'http://artemide.art.uniroma2.it:8081/agrovoc/rest/v1/data?uri=http://aims.fao.org/aos/agrovoc/c_9513')
            .to_return(status: 200, body: webmock_fixture('lod_agrovoc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
          lod_agrovoc.find('c_9513')
        end
        it 'has correct primary predicate values' do
          expect(results[:uri]).to eq('http://aims.fao.org/aos/agrovoc/c_9513')
          expect(results[:id]).to eq('http://aims.fao.org/aos/agrovoc/c_9513')
          expect(results[:label]).to eq ['buttermilk']
          expect(results[:broader]).to eq ['http://aims.fao.org/aos/agrovoc/c_4830']
          expect(results[:sameas]).to include('http://cat.aii.caas.cn/concept/c_26308', 'http://lod.nal.usda.gov/nalt/20627', 'http://d-nb.info/gnd/4147072-2')
        end

        it 'has correct number of predicates in pred-obj list' do
          expect(results['predicates'].count).to eq 12
        end

        it 'has primary predicates in pred-obj list' do
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#prefLabel']).to eq ['buttermilk']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#broader']).to eq ['http://aims.fao.org/aos/agrovoc/c_4830']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#exactMatch']).to include('http://cat.aii.caas.cn/concept/c_26308', 'http://lod.nal.usda.gov/nalt/20627', 'http://d-nb.info/gnd/4147072-2')
        end

        it 'has skos predicate values' do
          expect(results['predicates']['http://www.w3.org/2008/05/skos-xl#prefLabel']).to include('http://aims.fao.org/aos/agrovoc/xl_es_1299487482038', 'http://aims.fao.org/aos/agrovoc/xl_it_1299487482154', 'http://aims.fao.org/aos/agrovoc/xl_ko_1299487482210', 'http://aims.fao.org/aos/agrovoc/xl_pl_1299487482273', 'http://aims.fao.org/aos/agrovoc/xl_sk_1299487482378', 'http://aims.fao.org/aos/agrovoc/xl_en_1299487482019', 'http://aims.fao.org/aos/agrovoc/xl_tr_9513_1321792194941', 'http://aims.fao.org/aos/agrovoc/xl_de_1299487482000', 'http://aims.fao.org/aos/agrovoc/xl_fa_1299487482058', 'http://aims.fao.org/aos/agrovoc/xl_th_1299487482417', 'http://aims.fao.org/aos/agrovoc/xl_fr_1299487482080', 'http://aims.fao.org/aos/agrovoc/xl_hi_1299487482102', 'http://aims.fao.org/aos/agrovoc/xl_ar_1299487481966', 'http://aims.fao.org/aos/agrovoc/xl_ja_1299487482181', 'http://aims.fao.org/aos/agrovoc/xl_lo_1299487482240', 'http://aims.fao.org/aos/agrovoc/xl_ru_1299487482341', 'http://aims.fao.org/aos/agrovoc/xl_cs_1299487481982', 'http://aims.fao.org/aos/agrovoc/xl_zh_1299487482458', 'http://aims.fao.org/aos/agrovoc/xl_pt_1299487482307', 'http://aims.fao.org/aos/agrovoc/xl_hu_1299487482127')
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#inScheme']).to eq ['http://aims.fao.org/aos/agrovoc']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#closeMatch']).to eq ['http://dbpedia.org/resource/Buttermilk']
          expect(results['predicates']['http://www.w3.org/2008/05/skos-xl#altLabel']).to eq ['http://aims.fao.org/aos/agrovoc/xl_fa_1299487482544']
        end

        it 'has more unspecified predicate values' do
          expect(results['predicates']['http://www.w3.org/1999/02/22-rdf-syntax-ns#type']).to eq ['http://www.w3.org/2004/02/skos/core#Concept']
          expect(results['predicates']['http://purl.org/dc/terms/created']).to eq ['2011-11-20T20:29:54Z']
          expect(results['predicates']['http://purl.org/dc/terms/modified']).to eq ['2014-07-03T18:51:03Z']
          expect(results['predicates']['http://rdfs.org/ns/void#inDataset']).to eq ['http://aims.fao.org/aos/agrovoc/void.ttl#Agrovoc']
          expect(results['predicates']['http://art.uniroma2.it/ontologies/vocbench#hasStatus']).to eq ['Published']
        end
      end
    end

    context 'in LOC authority' do
      context 'term found' do
        let :results do
          stub_request(:get, 'http://id.loc.gov/authorities/subjects/sh85118553')
            .to_return(status: 200, body: webmock_fixture('lod_loc_term_found.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
          lod_loc.find('sh85118553', subauth: 'subjects')
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
          expect(results['predicates']['http://www.loc.gov/mads/rdf/v1#isMemberOfMADSCollection']).to include('http://id.loc.gov/authorities/subjects/collection_LCSHAuthorizedHeadings', 'http://id.loc.gov/authorities/subjects/collection_LCSH_General', 'http://id.loc.gov/authorities/subjects/collection_SubdivideGeographically')
          expect(results['predicates']['http://www.loc.gov/mads/rdf/v1#hasCloseExternalAuthority']).to include('http://data.bnf.fr/ark:/12148/cb12321484k', 'http://data.bnf.fr/ark:/12148/cb119673416', 'http://data.bnf.fr/ark:/12148/cb119934236', 'http://data.bnf.fr/ark:/12148/cb12062047t', 'http://data.bnf.fr/ark:/12148/cb119469567', 'http://data.bnf.fr/ark:/12148/cb11933232c', 'http://data.bnf.fr/ark:/12148/cb122890536', 'http://data.bnf.fr/ark:/12148/cb121155321', 'http://data.bnf.fr/ark:/12148/cb15556043g', 'http://data.bnf.fr/ark:/12148/cb123662513', 'http://d-nb.info/gnd/4066562-8', 'http://data.bnf.fr/ark:/12148/cb120745812', 'http://data.bnf.fr/ark:/12148/cb11973101n', 'http://data.bnf.fr/ark:/12148/cb13328497r')
          expect(results['predicates']['http://www.loc.gov/mads/rdf/v1#isMemberOfMADSScheme']).to eq ['http://id.loc.gov/authorities/subjects']
          expect(results['predicates']['http://www.loc.gov/mads/rdf/v1#editorialNote']).to eq ['headings beginning with the word [Scientific;] and subdivision [Science] under ethnic groups and individual wars, e.g. [World War, 1939-1945--Science]']
        end

        it 'has more unspecified predicate values' do
          expect(results['predicates']['http://www.w3.org/1999/02/22-rdf-syntax-ns#type']).to include('http://www.loc.gov/mads/rdf/v1#Topic', 'http://www.loc.gov/mads/rdf/v1#Authority', 'http://www.w3.org/2004/02/skos/core#Concept')
          expect(results['predicates']['http://www.w3.org/2002/07/owl#sameAs']).to include('info:lc/authorities/sh85118553', 'http://id.loc.gov/authorities/sh85118553#concept')
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#closeMatch']).to include('http://data.bnf.fr/ark:/12148/cb12321484k', 'http://data.bnf.fr/ark:/12148/cb119673416', 'http://data.bnf.fr/ark:/12148/cb119934236', 'http://data.bnf.fr/ark:/12148/cb12062047t', 'http://data.bnf.fr/ark:/12148/cb119469567', 'http://data.bnf.fr/ark:/12148/cb11933232c', 'http://data.bnf.fr/ark:/12148/cb122890536', 'http://data.bnf.fr/ark:/12148/cb121155321', 'http://data.bnf.fr/ark:/12148/cb15556043g', 'http://data.bnf.fr/ark:/12148/cb123662513', 'http://d-nb.info/gnd/4066562-8', 'http://data.bnf.fr/ark:/12148/cb120745812', 'http://data.bnf.fr/ark:/12148/cb11973101n', 'http://data.bnf.fr/ark:/12148/cb13328497r')
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#editorial']).to eq ['headings beginning with the word [Scientific;] and subdivision [Science] under ethnic groups and individual wars, e.g. [World War, 1939-1945--Science]']
          expect(results['predicates']['http://www.w3.org/2004/02/skos/core#inScheme']).to eq ['http://id.loc.gov/authorities/subjects']
        end
      end
    end

    describe "language processing" do
      context "when filtering #find result" do
        context "and lang NOT passed in" do
          context "and NO default defined in config" do
            let(:lod_lang_no_defaults) { described_class.new(:LOD_LANG_NO_DEFAULTS) }
            let :results do
              stub_request(:get, "http://localhost/test_no_default/term/c_9513")
                .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_no_defaults.find('c_9513')
            end
            it "is not filtered" do
              expect(results[:label]).to eq ['buttermilk', 'Babeurre']
              expect(results[:altlabel]).to eq ['yummy', 'délicieux']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to include("buttermilk", "Babeurre")
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to include("yummy", "délicieux")
            end
          end
          context "and default IS defined in config" do
            let(:lod_lang_defaults) { described_class.new(:LOD_LANG_DEFAULTS) }
            let :results do
              stub_request(:get, "http://localhost/test_default/term/c_9513")
                .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_defaults.find('c_9513')
            end
            it "is filtered to default" do
              expect(results[:label]).to eq ['buttermilk']
              expect(results[:altlabel]).to eq ['yummy']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to eq ['buttermilk']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to eq ['yummy']
            end
          end
          context "and multiple defaults ARE defined in config" do
            let(:lod_lang_multi_defaults) { described_class.new(:LOD_LANG_MULTI_DEFAULTS) }
            let :results do
              stub_request(:get, "http://localhost/test_default/term/c_9513")
                .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfrde.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_multi_defaults.find('c_9513')
            end
            it "is filtered to default" do
              expect(results[:label]).to eq ['buttermilk', 'Babeurre']
              expect(results[:altlabel]).to eq ['yummy', 'délicieux']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to include("buttermilk", "Babeurre")
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to include("yummy", "délicieux")
            end
          end
        end

        context "and lang IS passed in" do
          let(:lod_lang_defaults) { described_class.new(:LOD_LANG_DEFAULTS) }
          let :results do
            stub_request(:get, "http://localhost/test_default/term/c_9513")
              .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
            lod_lang_defaults.find('c_9513', language: 'fr')
          end
          it "is filtered to specified language" do
            expect(results[:label]).to eq ['Babeurre']
            expect(results[:altlabel]).to eq ['délicieux']
            expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to eq ['Babeurre']
            expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to eq ['délicieux']
          end
        end

        context "and result does not have altlabel" do
          let(:lod_lang_defaults) { described_class.new(:LOD_LANG_DEFAULTS) }
          let :results do
            stub_request(:get, "http://localhost/test_default/term/c_9513")
              .to_return(status: 200, body: webmock_fixture("lod_lang_term_enfr_noalt.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
            lod_lang_defaults.find('c_9513', language: 'fr')
          end
          it "is filtered to specified language" do
            expect(results[:label]).to eq ['Babeurre']
            expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to eq ['Babeurre']
          end
        end

        context "when replacement on authority term URL" do
          context "and using default" do
            let(:lod_lang_param) { described_class.new(:LOD_LANG_PARAM) }
            let :results do
              stub_request(:get, "http://localhost/test_replacement/term/c_9513?lang=en")
                .to_return(status: 200, body: webmock_fixture("lod_lang_term_en.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_param.find("c_9513")
            end
            it "is correctly parsed" do
              expect(results[:label]).to eq ['buttermilk']
              expect(results[:altlabel]).to eq ['yummy']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#prefLabel"]).to eq ['buttermilk']
              expect(results["predicates"]["http://www.w3.org/2004/02/skos/core#altLabel"]).to eq ['yummy']
            end
          end

          context "and lang specified" do
            let(:lod_lang_param) { described_class.new(:LOD_LANG_PARAM) }
            let :results do
              stub_request(:get, "http://localhost/test_replacement/term/c_9513?lang=fr")
                .to_return(status: 200, body: webmock_fixture("lod_lang_term_fr.rdf.xml"), headers: { 'Content-Type' => 'application/rdf+xml' })
              lod_lang_param.find("c_9513", replacements: { 'lang' => 'fr' })
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
  end

  describe '#new' do
    context 'without an authority' do
      it 'raises an exception' do
        expect { described_class.new }.to raise_error ArgumentError, /wrong number of arguments/
      end
    end
    context 'with an invalid authority' do
      it 'raises an exception' do
        expect { described_class.new(:FOO) }.to raise_error Qa::InvalidLinkedDataAuthority, /Unable to initialize linked data authority 'FOO'/
      end
    end
    context 'with a valid authority' do
      it 'creates the authority' do
        expect(described_class.new(:OCLC_FAST)).to be_kind_of described_class
      end
    end
  end

  context 'testing delegated method' do
    let(:full_authority) { described_class.new(:LOD_FULL_CONFIG) }
    let(:min_authority) { described_class.new(:LOD_MIN_CONFIG) }
    let(:search_only_authority) { described_class.new(:LOD_SEARCH_ONLY_CONFIG) }
    let(:term_only_authority) { described_class.new(:LOD_TERM_ONLY_CONFIG) }

    describe '#supports_search?' do
      it 'returns false if search is NOT configured' do
        expect(term_only_authority.supports_search?).to eq false
      end
      it 'returns true if search is configured' do
        expect(full_authority.supports_search?).to eq true
      end
    end

    describe '#search_subauthorities?' do
      it 'returns false if only term configuration is defined' do
        expect(term_only_authority.search_subauthorities?).to eq false
      end
      it 'returns false if the configuration does NOT define subauthorities' do
        expect(min_authority.search_subauthorities?).to eq false
      end
      it 'returns true if the configuration defines subauthorities' do
        expect(full_authority.search_subauthorities?).to eq true
      end
    end

    describe '#search_subauthority?' do
      it 'returns false if only term configuration is defined' do
        expect(term_only_authority.search_subauthority?('fake_subauth')).to eq false
      end
      it 'returns false if there are no subauthorities configured' do
        expect(min_authority.search_subauthority?('fake_subauth')).to eq false
      end
      it 'returns false if the requested subauthority is NOT configured' do
        expect(full_authority.search_subauthority?('fake_subauth')).to eq false
      end
      it 'returns true if the requested subauthority is configured' do
        expect(full_authority.search_subauthority?('search_sub2_key')).to eq true
      end
    end

    describe '#supports_term?' do
      it 'returns false if term is NOT configured' do
        expect(search_only_authority.supports_term?).to eq false
      end
      it 'returns true if term is configured' do
        expect(full_authority.supports_term?).to eq true
      end
    end

    describe '#term_subauthorities?' do
      it 'returns false if only search configuration is defined' do
        expect(search_only_authority.term_subauthorities?).to eq false
      end
      it 'returns false if the configuration does NOT define subauthorities' do
        expect(min_authority.term_subauthorities?).to eq false
      end
      it 'returns true if the configuration defines subauthorities' do
        expect(full_authority.term_subauthorities?).to eq true
      end
    end

    describe '#term_subauthority?' do
      it 'returns false if only search configuration is defined' do
        expect(search_only_authority.term_subauthority?('fake_subauth')).to eq false
      end
      it 'returns false if there are no subauthorities configured' do
        expect(min_authority.term_subauthority?('fake_subauth')).to eq false
      end
      it 'returns false if the requested subauthority is NOT configured' do
        expect(full_authority.term_subauthority?('fake_subauth')).to eq false
      end
      it 'returns true if the requested subauthority is configured' do
        expect(full_authority.term_subauthority?('term_sub2_key')).to eq true
      end
    end

    describe '#term_id_expects_id?' do
      it 'returns false if term_id specifies a URI is required' do
        expect(min_authority.term_id_expects_id?).to eq false
      end
      it 'returns true if term_id specifies an ID is required' do
        expect(full_authority.term_id_expects_id?).to eq true
      end
    end

    describe '#term_id_expects_uri?' do
      it 'returns false if term_id specifies a ID is required' do
        expect(full_authority.term_id_expects_uri?).to eq false
      end
      it 'returns true if term_id specifies an URI is required' do
        expect(min_authority.term_id_expects_uri?).to eq true
      end
    end
  end
end
