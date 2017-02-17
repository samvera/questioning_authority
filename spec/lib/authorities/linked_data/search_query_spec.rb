require 'spec_helper'

describe Qa::Authorities::LinkedData::GenericAuthority do
  let(:lod_oclc) { described_class.new(:OCLC_FAST) }
  let(:lod_agrovoc) { described_class.new(:AGROVOC) }

  describe '#search' do
    context 'in OCLC_FAST authority' do
      context '0 search results' do
        let :results do
          stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22supercalifragilisticexpialidocious%22&sortKeys=usage')
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
          stub_request(:get, 'http://aims.fao.org/skosmos/rest/v1/search/?lang=en&query=*supercalifragilisticexpialidocious*')
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
            .to_return(status: 200, body: webmock_fixture('lod_agrovoc_query_no_results.json'), headers: { 'Content-Type' => 'application/json' })
          lod_agrovoc.search('supercalifragilisticexpialidocious')
        end
        it 'returns an empty array' do
          expect(results).to eq([])
        end
      end

      context '3 search results' do
        let :results do
          stub_request(:get, 'http://aims.fao.org/skosmos/rest/v1/search/?lang=en&query=*milk*')
            .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
    #   # let(:lod_loc) { described_class.new(:LOC) }
    # end

    describe "language processing" do
      context "when filtering #search results" do
        context "and lang NOT passed in" do
          context "and NO default defined in config" do
            let(:lod_lang_no_defaults) { described_class.new(:LOD_LANG_NO_DEFAULTS) }
            let :results do
              stub_request(:get, "http://localhost/test_no_default/search?query=milk")
                .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
                .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
              .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
              .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
                .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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
                .with(headers: { 'Accept' => 'application/n-triples, text/plain;q=0.2, application/n-quads, text/x-nquads;q=0.2, application/ld+json, application/x-ld+json, application/rdf+json, text/html;q=0.5, application/xhtml+xml;q=0.7, image/svg+xml;q=0.4, text/n3, text/rdf+n3;q=0.2, application/rdf+n3;q=0.2, text/turtle, text/rdf+turtle, application/turtle;q=0.2, application/x-turtle;q=0.2, application/rdf+xml, text/csv;q=0.4, text/tab-separated-values;q=0.4, application/csvm+json, application/trig, application/x-trig, application/trix, */*;q=0.1', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
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

  describe "#sort_search_results" do
    let(:lod_sort) { described_class.new(:LOD_SORT) }
    let(:term_a) { "alpha" }
    let(:term_b) { "bravo" }
    let(:term_c) { "charlie" }
    let(:term_d) { "delta" }

    context "when sort term is empty" do
      context "for all" do
        it "does not change order" do
          json_results = [{ label: "[#{term_b}]", sort: [""] }, { label: "[#{term_a}]", sort: [""] }, { label: "[#{term_c}]", sort: [""] }]
          expect(lod_sort.send(:sort_search_results, json_results)).to eq json_results
        end
      end

      context "for one" do
        it "puts empty first" do
          json_results = [{ label: "[#{term_b}]", sort: [""] }, { label: "[#{term_c}]", sort: [term_c] }, { label: "[#{term_a}]", sort: [term_a] }]
          expected_results = [{ label: "[#{term_b}]" }, { label: "[#{term_a}]" }, { label: "[#{term_c}]" }]
          expect(lod_sort.send(:sort_search_results, json_results)).to eq expected_results
        end
      end
    end

    context "when sort term is single value" do
      context "for all" do
        it "sorts on the single value" do
          json_results = [{ label: "[#{term_b}]", sort: [term_b] }, { label: "[#{term_c}]", sort: [term_c] }, { label: "[#{term_a}]", sort: [term_a] }]
          expected_results = [{ label: "[#{term_a}]" }, { label: "[#{term_b}]" }, { label: "[#{term_c}]" }]
          expect(lod_sort.send(:sort_search_results, json_results)).to eq expected_results
        end
      end
    end

    context "when first sort term is same" do
      it "sorts on second sort term" do
        json_results = [{ label: "[#{term_b}, #{term_c}]", sort: [term_b, term_c] }, { label: "[#{term_b}, #{term_d}]", sort: [term_b, term_d] }, { label: "[#{term_b}, #{term_a}]", sort: [term_b, term_a] }]
        expected_results = [{ label: "[#{term_b}, #{term_a}]" }, { label: "[#{term_b}, #{term_c}]" }, { label: "[#{term_b}, #{term_d}]" }]
        expect(lod_sort.send(:sort_search_results, json_results)).to eq expected_results
      end
    end

    context "when different number of sort terms" do
      context "and initial terms match" do
        it "puts shorter set of terms before longer set" do
          json_results = [{ label: "[#{term_b}, #{term_c}]", sort: [term_b, term_c] }, { label: "[#{term_b}]", sort: [term_b] }, { label: "[#{term_b}, #{term_a}]", sort: [term_b, term_a] }]
          expected_results = [{ label: "[#{term_b}]" }, { label: "[#{term_b}, #{term_a}]" }, { label: "[#{term_b}, #{term_c}]" }]
          expect(lod_sort.send(:sort_search_results, json_results)).to eq expected_results
        end
      end

      context "and a difference happens before end of term sets" do
        it "stops ordering as soon as a difference is found" do
          json_results = [{ label: "[#{term_b}, #{term_d}, #{term_c}]", sort: [term_b, term_d, term_c] }, { label: "[#{term_a}, #{term_c}]", sort: [term_a, term_c] }, { label: "[#{term_b}, #{term_d}, #{term_a}]", sort: [term_b, term_d, term_a] }]
          expected_results = [{ label: "[#{term_a}, #{term_c}]" }, { label: "[#{term_b}, #{term_d}, #{term_a}]" }, { label: "[#{term_b}, #{term_d}, #{term_c}]" }]
          expect(lod_sort.send(:sort_search_results, json_results)).to eq expected_results
        end
      end
    end
  end
end
