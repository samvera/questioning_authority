require 'spec_helper'
require 'qa/authorities/linked_data/config/term_config'

describe Qa::Authorities::LinkedData::TermConfig do
  let(:full_config) { Qa::Authorities::LinkedData::Config.new(:LOD_FULL_CONFIG).term }
  let(:min_config) { Qa::Authorities::LinkedData::Config.new(:LOD_MIN_CONFIG).term }
  let(:search_only_config) { Qa::Authorities::LinkedData::Config.new(:LOD_SEARCH_ONLY_CONFIG).term }
  let(:encoding_config) { Qa::Authorities::LinkedData::Config.new(:LOD_ENCODING_CONFIG).term }

  let(:ldpath_results_config) do
    {
      id_ldpath:       'schema:identifier ::xsd:string',
      label_ldpath:    'skos:prefLabel ::xsd:string',
      altlabel_ldpath: 'skos:altLabel ::xsd:string',
      broader_ldpath:  'skos:broader ::xsd:string',
      narrower_ldpath: 'skos:narrower ::xsd:string',
      sameas_ldpath:   'skos:exactMatch ::xsd:string'
    }
  end

  describe '#term_config' do
    let(:full_term_config) do
      {
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
      }
    end

    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.send(:term_config)).to be_empty
    end
    it 'returns hash of term configuration' do
      expect(full_config.send(:term_config)).to eq full_term_config
    end
  end

  describe '#supports_term?' do
    it 'returns false if term is NOT configured' do
      expect(search_only_config.supports_term?).to eq false
    end
    it 'returns true if term is configured' do
      expect(full_config.supports_term?).to eq true
    end
  end

  describe '#url_config' do
    let(:url_config) do
      {
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
      }
    end

    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.url_config).to eq nil
    end
    it 'returns the url config from the configuration' do
      expect(full_config.url_config).to be_kind_of Qa::IriTemplate::UrlConfig
    end
  end

  describe '#term_id_expects_id?' do
    it 'returns false if term_id specifies a URI is required' do
      expect(min_config.term_id_expects_id?).to eq false
    end
    it 'returns true if term_id specifies an ID is required' do
      expect(full_config.term_id_expects_id?).to eq true
    end
  end

  describe '#term_id_expects_uri?' do
    it 'returns false if term_id specifies a ID is required' do
      expect(full_config.term_id_expects_uri?).to eq false
    end
    it 'returns true if term_id specifies an URI is required' do
      expect(min_config.term_id_expects_uri?).to eq true
    end
  end

  describe '#term_language' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_language).to eq nil
    end
    it 'returns nil if language is not specified' do
      expect(min_config.term_language).to eq nil
    end
    it 'returns the preferred language for selecting literal values if configured for term' do
      expect(full_config.term_language).to eq [:es]
    end
  end

  describe '#term_results' do
    let(:results_config) do
      {
        id_predicate: 'http://purl.org/dc/terms/identifier',
        label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
        altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
        broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader',
        narrower_predicate: 'http://www.w3.org/2004/02/skos/core#narrower',
        sameas_predicate: 'http://www.w3.org/2004/02/skos/core#exactMatch'
      }
    end
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results).to eq nil
    end
    it 'returns hash of predicates' do
      expect(full_config.term_results).to eq results_config
    end
  end

  describe '#term_results_id_predicate' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_id_predicate).to eq nil
    end
    it 'returns the predicate that holds the ID in term results' do
      expect(full_config.term_results_id_predicate).to eq RDF::URI('http://purl.org/dc/terms/identifier')
    end
  end

  describe '#term_results_id_ldpath' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_id_ldpath).to eq nil
    end

    context 'when id specified as ldpath' do
      before { allow(full_config).to receive(:term_results).and_return(ldpath_results_config) }
      it 'returns the ldpath' do
        expect(full_config.term_results_id_ldpath).to eq 'schema:identifier ::xsd:string'
      end
    end
  end

  describe '#term_results_label_predicate' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_label_predicate).to eq nil
    end
    it 'returns the predicate that holds the label in term results' do
      expect(full_config.term_results_label_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#prefLabel')
    end
  end

  describe '#term_results_label_ldpath' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_label_ldpath).to eq nil
    end

    context 'when label specified as ldpath' do
      before { allow(full_config).to receive(:term_results).and_return(ldpath_results_config) }
      it 'returns the ldpath' do
        expect(full_config.term_results_label_ldpath).to eq 'skos:prefLabel ::xsd:string'
      end
    end
  end

  describe '#term_results_altlabel_predicate' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_altlabel_predicate).to eq nil
    end
    it 'return nil if altlabel predicate is not defined' do
      expect(min_config.term_results_altlabel_predicate).to eq nil
    end
    it 'returns the predicate that holds the altlabel in term results' do
      expect(full_config.term_results_altlabel_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#altLabel')
    end
  end

  describe '#term_results_altlabel_ldpath' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_altlabel_ldpath).to eq nil
    end
    it 'return nil if altlabel predicate is not defined' do
      expect(min_config.term_results_altlabel_ldpath).to eq nil
    end

    context 'when altlabel specified as ldpath' do
      before { allow(full_config).to receive(:term_results).and_return(ldpath_results_config) }
      it 'returns the ldpath' do
        expect(full_config.term_results_altlabel_ldpath).to eq 'skos:altLabel ::xsd:string'
      end
    end
  end

  describe '#term_results_broader_predicate' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_broader_predicate).to eq nil
    end
    it 'return nil if broader predicate is not defined' do
      expect(min_config.term_results_broader_predicate).to eq nil
    end
    it 'returns the predicate that holds any broader terms in term results' do
      expect(full_config.term_results_broader_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#broader')
    end
  end

  describe '#term_results_broader_ldpath' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_broader_ldpath).to eq nil
    end
    it 'return nil if broader predicate is not defined' do
      expect(min_config.term_results_broader_ldpath).to eq nil
    end

    context 'when broader specified as ldpath' do
      before { allow(full_config).to receive(:term_results).and_return(ldpath_results_config) }
      it 'returns the ldpath' do
        expect(full_config.term_results_broader_ldpath).to eq 'skos:broader ::xsd:string'
      end
    end
  end

  describe '#term_results_narrower_predicate' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_narrower_predicate).to eq nil
    end
    it 'return nil if narrower predicate is not defined' do
      expect(min_config.term_results_narrower_predicate).to eq nil
    end
    it 'returns the predicate that holds any narrower terms in term results' do
      expect(full_config.term_results_narrower_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#narrower')
    end
  end

  describe '#term_results_narrower_ldpath' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_narrower_ldpath).to eq nil
    end
    it 'return nil if narrower predicate is not defined' do
      expect(min_config.term_results_narrower_ldpath).to eq nil
    end

    context 'when narrower specified as ldpath' do
      before { allow(full_config).to receive(:term_results).and_return(ldpath_results_config) }
      it 'returns the ldpath' do
        expect(full_config.term_results_narrower_ldpath).to eq 'skos:narrower ::xsd:string'
      end
    end
  end

  describe '#term_results_sameas_predicate' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_sameas_predicate).to eq nil
    end
    it 'return nil if sameas predicate is not defined' do
      expect(min_config.term_results_sameas_predicate).to eq nil
    end
    it 'returns the predicate that holds any sameas terms in term results' do
      expect(full_config.term_results_sameas_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#exactMatch')
    end
  end

  describe '#term_results_sameas_ldpath' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_sameas_ldpath).to eq nil
    end
    it 'return nil if sameas predicate is not defined' do
      expect(min_config.term_results_sameas_ldpath).to eq nil
    end

    context 'when sameas specified as ldpath' do
      before { allow(full_config).to receive(:term_results).and_return(ldpath_results_config) }
      it 'returns the ldpath' do
        expect(full_config.term_results_sameas_ldpath).to eq 'skos:exactMatch ::xsd:string'
      end
    end
  end

  describe '#supports_language_parameter?' do
    it 'returns false if only search configuration is defined' do
      expect(search_only_config.supports_language_parameter?).to eq false
    end
    it 'returns false if the configuration does NOT define the lang replacement' do
      expect(min_config.supports_language_parameter?).to eq false
    end
    it 'returns true if the configuration defines the lang replacement' do
      expect(full_config.supports_language_parameter?).to eq true
    end
  end

  describe '#supports_subauthorities?' do
    it 'returns false if only search configuration is defined' do
      expect(search_only_config.supports_subauthorities?).to eq false
    end
    it 'returns false if the configuration does NOT define the subauth replacement' do
      expect(min_config.supports_subauthorities?).to eq false
    end
    it 'returns true if the configuration defines the subauth replacement' do
      expect(full_config.supports_subauthorities?).to eq true
    end
  end

  describe '#term_subauthorities?' do
    it 'returns false if only search configuration is defined' do
      expect(search_only_config.term_subauthorities?).to eq false
    end
    it 'returns false if the configuration does NOT define subauthorities' do
      expect(min_config.term_subauthorities?).to eq false
    end
    it 'returns true if the configuration defines subauthorities' do
      expect(full_config.term_subauthorities?).to eq true
    end
  end

  describe '#term_subauthority?' do
    it 'returns false if only search configuration is defined' do
      expect(search_only_config.term_subauthority?('fake_subauth')).to eq false
    end
    it 'returns false if there are no subauthorities configured' do
      expect(min_config.term_subauthority?('fake_subauth')).to eq false
    end
    it 'returns false if the requested subauthority is NOT configured' do
      expect(full_config.term_subauthority?('fake_subauth')).to eq false
    end
    it 'returns true if the requested subauthority is configured' do
      expect(full_config.term_subauthority?('term_sub2_key')).to eq true
    end
  end

  describe '#term_subauthority_count' do
    it 'returns 0 if only search configuration is defined' do
      expect(search_only_config.term_subauthority_count).to eq 0
    end
    it 'returns 0 if the configuration does NOT define subauthorities' do
      expect(min_config.term_subauthority_count).to eq 0
    end
    it 'returns the number of subauthorities if defined' do
      expect(full_config.term_subauthority_count).to eq 3
    end
  end

  describe '#term_subauthorities' do
    it 'returns empty hash if only search configuration is defined' do
      empty_hash = {}
      expect(search_only_config.term_subauthorities).to eq empty_hash
    end
    it 'returns empty hash if no subauthorities are defined' do
      empty_hash = {}
      expect(min_config.term_subauthorities).to eq empty_hash
    end
    it 'returns hash of all subauthority key-value patterns defined' do
      expected_hash = {
        term_sub1_key: 'term_sub1_name',
        term_sub2_key: 'term_sub2_name',
        term_sub3_key: 'term_sub3_name'
      }
      expect(full_config.term_subauthorities).to eq expected_hash
    end
  end
end
