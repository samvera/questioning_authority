require 'spec_helper'

describe Qa::Authorities::LinkedData::Config do
  let(:full_config) { described_class.new(:LOD_FULL_CONFIG) }

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

  describe '#auth_config' do
    let(:full_auth_config) do
      {
        term: {
          url: {
            :@context => 'http://www.w3.org/ns/hydra/context.jsonld',
            :@type => 'IriTemplate',
            template: 'http://localhost/test_default/term/{?subauth}/{?term_id}?param1={?param1}&param2={?param2}',
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
            template: 'http://localhost/test_default/search?subauth={?subauth}&query={?query}&param1={?param1}&param2={?param2}',
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
          subauthorities: {
            search_sub1_key: 'search_sub1_name',
            search_sub2_key: 'search_sub2_name',
            search_sub3_key: 'search_sub3_name'
          }
        }
      }
    end

    it 'returns hash of the full authority configuration' do
      expect(full_config.auth_config).to eq full_auth_config
    end
  end
end
