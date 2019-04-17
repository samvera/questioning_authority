require 'spec_helper'

describe Qa::Authorities::LinkedData::Config do
  let(:full_config) { described_class.new(:LOD_FULL_CONFIG) }
  let(:full_config_1_0) { described_class.new(:LOD_FULL_CONFIG_1_0) }

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

  describe '#authority_config' do
    let(:full_auth_config) do
      {
        QA_CONFIG_VERSION: "2.0",
        prefixes: {
          schema: "http://www.w3.org/2000/01/rdf-schema#",
          skos: "http://www.w3.org/2004/02/skos/core#"
        },
        term: {
          url: {
            :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
            :@type => 'IriTemplate',
            template: 'http://localhost/test_default/term/{subauth}/{term_id}?{?param1}&{?param2}&{?lang}',
            variableRepresentation: 'BasicRepresentation',
            mapping: [
              {
                :@type => 'IriTemplateMapping',
                variable: 'term_id',
                property: 'hydra:freetextQuery',
                required: true
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'subauth',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'term_sub2_name'
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'param1',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'alpha'
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'param2',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'beta'
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'lang',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'de'
              }
            ]
          },
          qa_replacement_patterns: {
            term_id: 'term_id',
            subauth: 'subauth',
            lang: 'lang'
          },
          term_id: 'ID',
          language: ['es'],
          results: {
            id_predicate: 'http://purl.org/dc/terms/identifier',
            label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
            altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
            broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader',
            narrower_predicate: 'http://www.w3.org/2004/02/skos/core#narrower',
            sameas_predicate: 'http://www.w3.org/2004/02/skos/core#exactMatch'
          },
          subauthorities: {
            term_sub1_key: 'term_sub1_name',
            term_sub2_key: 'term_sub2_name',
            term_sub3_key: 'term_sub3_name'
          }
        },
        search: {
          url: {
            :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
            :@type => 'IriTemplate',
            template: 'http://localhost/test_default/search?{?subauth}&{?query}&{?param1}&{?param2}&{?lang}',
            variableRepresentation: 'BasicRepresentation',
            mapping: [
              {
                :@type => 'IriTemplateMapping',
                variable: 'query',
                property: 'hydra:freetextQuery',
                required: true
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'subauth',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'search_sub1_name'
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'param1',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'delta'
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'param2',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'echo'
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'lang',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'fr'
              }
            ]
          },
          qa_replacement_patterns: {
            query: 'query',
            subauth: 'subauth',
            lang: 'lang'
          },
          language: ['en', 'fr', 'de'],
          results: {
            id_predicate: 'http://purl.org/dc/terms/identifier',
            label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
            altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
            sort_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel'
          },
          context: {
            groups: {
              dates: {
                group_label_i18n: "qa.linked_data.authority.locnames_ld4l_cache.dates",
                group_label_default: "Dates"
              },
              hierarchy: {
                group_label_i18n: "qa.linked_data.authority.locgenres_ld4l_cache.hierarchy",
                group_label_default: "Hierarchy"
              }
            },
            properties: [
              {
                property_label_i18n: "qa.linked_data.authority.locgenres_ld4l_cache.authoritative_label",
                property_label_default: "Authoritative Label",
                ldpath: "madsrdf:authoritativeLabel",
                selectable: true,
                drillable: false
              },
              {
                group_id: "dates",
                property_label_i18n: "qa.linked_data.authority.locnames_ld4l_cache.birth_date",
                property_label_default: "Birth",
                ldpath: "madsrdf:identifiesRWO/madsrdf:birthDate/schema:label",
                selectable: false,
                drillable: false
              },
              {
                group_id: "hierarchy",
                property_label_i18n: "qa.linked_data.authority.locgenres_ld4l_cache.narrower",
                property_label_default: "Narrower",
                ldpath: "skos:narrower :: xsd:string",
                selectable: true,
                drillable: true,
                expansion_label_ldpath: "skos:prefLabel ::xsd:string",
                expansion_id_ldpath: "loc:lccn ::xsd:string"
              },
              {
                group_id: "hierarchy",
                property_label_i18n: "qa.linked_data.authority.locgenres_ld4l_cache.broader",
                property_label_default: "Broader",
                ldpath: "skos:broader :: xsd:string",
                selectable: true,
                drillable: true,
                expansion_label_ldpath: "skos:prefLabel ::xsd:string",
                expansion_id_ldpath: "loc:lccn ::xsd:string"
              }
            ]
          },
          subauthorities: {
            search_sub1_key: 'search_sub1_name',
            search_sub2_key: 'search_sub2_name',
            search_sub3_key: 'search_sub3_name'
          }
        }
      }
    end

    let(:full_auth_config_1_0) do
      {
        prefixes: {
          schema: "http://www.w3.org/2000/01/rdf-schema#",
          skos: "http://www.w3.org/2004/02/skos/core#"
        },
        term: {
          url: {
            :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
            :@type => 'IriTemplate',
            template: 'http://localhost/test_default/term/{subauth}/{term_id}?param1={param1}&param2={param2}',
            variableRepresentation: 'BasicRepresentation',
            mapping: [
              {
                :@type => 'IriTemplateMapping',
                variable: 'term_id',
                property: 'hydra:freetextQuery',
                required: true
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'subauth',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'term_sub2_name'
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'param1',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'alpha'
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'param2',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'beta'
              }
            ]
          },
          qa_replacement_patterns: {
            term_id: 'term_id',
            subauth: 'subauth'
          },
          term_id: 'ID',
          language: ['en'],
          results: {
            id_predicate: 'http://purl.org/dc/terms/identifier',
            label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
            altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
            broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader',
            narrower_predicate: 'http://www.w3.org/2004/02/skos/core#narrower',
            sameas_predicate: 'http://www.w3.org/2004/02/skos/core#exactMatch'
          },
          subauthorities: {
            term_sub1_key: 'term_sub1_name',
            term_sub2_key: 'term_sub2_name',
            term_sub3_key: 'term_sub3_name'
          }
        },
        search: {
          url: {
            :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
            :@type => 'IriTemplate',
            template: 'http://localhost/test_default/search?subauth={subauth}&query={query}&param1={param1}&param2={param2}',
            variableRepresentation: 'BasicRepresentation',
            mapping: [
              {
                :@type => 'IriTemplateMapping',
                variable: 'query',
                property: 'hydra:freetextQuery',
                required: true
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'subauth',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'search_sub1_name'
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'param1',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'delta'
              },
              {
                :@type => 'IriTemplateMapping',
                variable: 'param2',
                property: 'hydra:freetextQuery',
                required: false,
                default: 'echo'
              }
            ]
          },
          qa_replacement_patterns: {
            query: 'query',
            subauth: 'subauth'
          },
          language: ['en', 'fr', 'de'],
          results: {
            id_predicate: 'http://purl.org/dc/terms/identifier',
            label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
            altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
            sort_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel'
          },
          context: {
            groups: {
              dates: {
                group_label_i18n: "qa.linked_data.authority.locnames_ld4l_cache.dates",
                group_label_default: "Dates"
              },
              hierarchy: {
                group_label_i18n: "qa.linked_data.authority.locgenres_ld4l_cache.hierarchy",
                group_label_default: "Hierarchy"
              }
            },
            properties: [
              {
                property_label_i18n: "qa.linked_data.authority.locgenres_ld4l_cache.authoritative_label",
                property_label_default: "Authoritative Label",
                ldpath: "madsrdf:authoritativeLabel",
                selectable: true,
                drillable: false
              },
              {
                group_id: "dates",
                property_label_i18n: "qa.linked_data.authority.locnames_ld4l_cache.birth_date",
                property_label_default: "Birth",
                ldpath: "madsrdf:identifiesRWO/madsrdf:birthDate/schema:label",
                selectable: false,
                drillable: false
              },
              {
                group_id: "hierarchy",
                property_label_i18n: "qa.linked_data.authority.locgenres_ld4l_cache.narrower",
                property_label_default: "Narrower",
                ldpath: "skos:narrower :: xsd:string",
                selectable: true,
                drillable: true,
                expansion_label_ldpath: "skos:prefLabel ::xsd:string",
                expansion_id_ldpath: "loc:lccn ::xsd:string"
              },
              {
                group_id: "hierarchy",
                property_label_i18n: "qa.linked_data.authority.locgenres_ld4l_cache.broader",
                property_label_default: "Broader",
                ldpath: "skos:broader :: xsd:string",
                selectable: true,
                drillable: true,
                expansion_label_ldpath: "skos:prefLabel ::xsd:string",
                expansion_id_ldpath: "loc:lccn ::xsd:string"
              }
            ]
          },
          subauthorities: {
            search_sub1_key: 'search_sub1_name',
            search_sub2_key: 'search_sub2_name',
            search_sub3_key: 'search_sub3_name'
          }
        }
      }
    end

    let(:authority_config) { full_config.authority_config }
    let(:authority_config_1_0) { full_config_1_0.authority_config }

    it 'returns hash of the full authority 2.0 configuration' do
      expect(authority_config).to eq full_auth_config
    end

    it 'returns hash of 1.0 configuration converting all {?var} to {var}' do
      expect(authority_config_1_0).to eq full_auth_config_1_0
    end
  end

  describe '#search' do
    it 'returns instance of search config class' do
      expect(full_config.search).to be_kind_of Qa::Authorities::LinkedData::SearchConfig
    end
  end

  describe '#term' do
    it 'returns instance of term config class' do
      expect(full_config.term).to be_kind_of Qa::Authorities::LinkedData::TermConfig
    end
  end

  describe '#prefixes' do
    let(:expected_results) do
      {
        schema: "http://www.w3.org/2000/01/rdf-schema#",
        skos: "http://www.w3.org/2004/02/skos/core#"
      }
    end

    it 'returns hash of prefix definitions' do
      expect(full_config.prefixes).to be_kind_of Hash
      expect(full_config.prefixes).to eq expected_results
    end
  end

  describe '#config_version' do
    context 'when version is NOT in the config file' do
      it 'returns default as 1.0' do
        expect(full_config_1_0.config_version).to eq '1.0'
      end
    end

    context 'when version is specified in the config file' do
      it 'returns the version from the config file' do
        expect(full_config.config_version).to eq '2.0'
      end
    end
  end

  describe '#config_version?' do
    it "returns true if the passed in version matches the authority's version" do
      expect(full_config.config_version?('2.0')).to eq true
    end

    it "returns false if the passed in version does NOT match the authority's version" do
      expect(full_config_1_0.config_version?('2.0')).to eq false
    end
  end
end
