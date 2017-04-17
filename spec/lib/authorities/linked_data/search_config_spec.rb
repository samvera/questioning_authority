require 'spec_helper'

RSpec.describe Qa::Authorities::LinkedData::SearchConfig do
  let(:full_config) { Qa::Authorities::LinkedData::Config.new(:LOD_FULL_CONFIG).search }
  let(:min_config) { Qa::Authorities::LinkedData::Config.new(:LOD_MIN_CONFIG).search }
  let(:term_only_config) { Qa::Authorities::LinkedData::Config.new(:LOD_TERM_ONLY_CONFIG).search }

  describe '#search_config' do
    let(:full_search_config) do
      {
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
    end

    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.send(:search_config)).to be_empty
    end
    it 'returns hash of search configuration' do
      expect(full_config.send(:search_config)).to eq full_search_config
    end
  end

  describe '#supports_search?' do
    it 'returns false if search is NOT configured' do
      expect(term_only_config.supports_search?).to eq false
    end
    it 'returns true if search is configured' do
      expect(full_config.supports_search?).to eq true
    end
  end

  describe '#url' do
    let(:url_config) do
      {
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
      }
    end

    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.url).to eq nil
    end
    it 'returns the search url from the configuration' do
      expect(full_config.url).to eq url_config
    end
  end

  describe '#url_template' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.url).to eq nil
    end
    it 'returns the search url from the configuration' do
      expected_url_template = 'http://localhost/test_default/search?subauth={?subauth}&query={?query}&param1={?param1}&param2={?param2}'
      expect(full_config.url_template).to eq expected_url_template
    end
  end

  describe '#language' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.language).to eq nil
    end
    it 'returns nil if language is not specified' do
      expect(min_config.language).to eq nil
    end
    it 'returns the preferred language for selecting literal values if configured for search' do
      expect(full_config.language).to eq [:en, :fr, :de]
    end
  end

  describe '#results' do
    let(:results_config) do
      {
        id_predicate: 'http://purl.org/dc/terms/identifier',
        label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
        altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
        sort_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel'
      }
    end

    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.results).to eq nil
    end
    it 'returns hash of predicates' do
      expect(full_config.results).to eq results_config
    end
  end

  describe '#results_id_predicate' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.results_id_predicate).to eq nil
    end
    it 'returns the predicate that holds the ID in search results' do
      expect(full_config.results_id_predicate).to eq RDF::URI('http://purl.org/dc/terms/identifier')
    end
  end

  describe '#results_label_predicate' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.results_label_predicate).to eq nil
    end
    it 'returns the predicate that holds the label in search results' do
      expect(full_config.results_label_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#prefLabel')
    end
  end

  describe '#results_altlabel_predicate' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.results_altlabel_predicate).to eq nil
    end
    it 'return nil if altlabel predicate is not defined' do
      expect(min_config.results_altlabel_predicate).to eq nil
    end
    it 'returns the predicate that holds the altlabel in search results' do
      expect(full_config.results_altlabel_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#altLabel')
    end
  end

  describe '#supports_sort?' do
    it 'returns false if only term configuration is defined' do
      expect(term_only_config.supports_sort?).to eq false
    end
    it 'returns false if sort predicate is NOT defined' do
      expect(min_config.supports_sort?).to eq false
    end
    it 'returns true if sort predicate IS defined' do
      expect(full_config.supports_sort?).to eq true
    end
  end

  describe '#results_sort_predicate' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.results_sort_predicate).to eq nil
    end
    it 'returns nil if sort predicate is not defined' do
      expect(min_config.results_sort_predicate).to eq nil
    end
    it 'returns the predicate on which results should be sorted' do
      expect(full_config.results_sort_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#prefLabel')
    end
  end

  describe '#replacements?' do
    it 'returns false if only term configuration is defined' do
      expect(term_only_config.replacements?).to eq false
    end
    it 'returns false if the configuration does NOT define replacements' do
      expect(min_config.replacements?).to eq false
    end
    it 'returns true if the configuration defines replacements' do
      expect(full_config.replacements?).to eq true
    end
  end

  describe '#replacement_count' do
    it 'returns 0 if only term configuration is defined' do
      expect(term_only_config.replacement_count).to eq 0
    end
    it 'returns 0 if replacement_count is NOT defined' do
      expect(min_config.replacement_count).to eq 0
    end
    it 'returns the number of replacements if defined' do
      expect(full_config.replacement_count).to eq 2
    end
  end

  describe '#replacements' do
    it 'returns empty hash if only term configuration is defined' do
      empty_hash = {}
      expect(term_only_config.replacements).to eq empty_hash
    end
    it 'returns empty hash if no replacement patterns are defined' do
      empty_hash = {}
      expect(min_config.replacements).to eq empty_hash
    end
    it 'returns hash of all replacement patterns' do
      expected_hash = {
        param1: { :@type => 'IriTemplateMapping', variable: 'param1', property: 'hydra:freetextQuery', required: false, default: 'delta' },
        param2: { :@type => 'IriTemplateMapping', variable: 'param2', property: 'hydra:freetextQuery', required: false, default: 'echo' }
      }
      expect(full_config.replacements).to eq expected_hash
    end
  end

  describe '#subauthorities?' do
    it 'returns false if only term configuration is defined' do
      expect(term_only_config.subauthorities?).to eq false
    end
    it 'returns false if the configuration does NOT define subauthorities' do
      expect(min_config.subauthorities?).to eq false
    end
    it 'returns true if the configuration defines subauthorities' do
      expect(full_config.subauthorities?).to eq true
    end
  end

  describe '#subauthority?' do
    it 'returns false if only term configuration is defined' do
      expect(term_only_config.subauthority?('fake_subauth')).to eq false
    end
    it 'returns false if there are no subauthorities configured' do
      expect(min_config.subauthority?('fake_subauth')).to eq false
    end
    it 'returns false if the requested subauthority is NOT configured' do
      expect(full_config.subauthority?('fake_subauth')).to eq false
    end
    it 'returns true if the requested subauthority is configured' do
      expect(full_config.subauthority?('search_sub2_key')).to eq true
    end
  end

  describe '#subauthority_count' do
    it 'returns 0 if only term configuration is defined' do
      expect(term_only_config.subauthority_count).to eq 0
    end
    it 'returns 0 if the configuration does NOT define subauthorities' do
      expect(min_config.subauthority_count).to eq 0
    end
    it 'returns the number of subauthorities if defined' do
      expect(full_config.subauthority_count).to eq 3
    end
  end

  describe '#subauthorities' do
    it 'returns empty hash if only term configuration is defined' do
      empty_hash = {}
      expect(term_only_config.subauthorities).to eq empty_hash
    end
    it 'returns empty hash if no subauthorities are defined' do
      empty_hash = {}
      expect(min_config.subauthorities).to eq empty_hash
    end
    it 'returns hash of all subauthority key-value patterns defined' do
      expected_hash = {
        search_sub1_key: 'search_sub1_name',
        search_sub2_key: 'search_sub2_name',
        search_sub3_key: 'search_sub3_name'
      }
      expect(full_config.subauthorities).to eq expected_hash
    end
  end

  describe '#subauthority_replacement_pattern' do
    it 'returns empty hash if only term configuration is defined' do
      empty_hash = {}
      expect(term_only_config.subauthority_replacement_pattern).to eq empty_hash
    end
    it 'returns empty hash if no subauthorities are defined' do
      empty_hash = {}
      expect(min_config.subauthority_replacement_pattern).to eq empty_hash
    end
    it 'returns hash replacement pattern for subauthority and the default value' do
      expected_hash = { pattern: 'subauth', default: 'search_sub1_name' }
      expect(full_config.subauthority_replacement_pattern).to eq expected_hash
    end
  end

  describe '#search_url_with_replacements' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.url_with_replacements('Smith')).to eq nil
    end
    it 'returns the url with query substitution applied' do
      expected_url = 'http://localhost/test_default/search?subauth=search_sub1_name&query=Smith&param1=delta&param2=echo'
      expect(full_config.url_with_replacements('Smith')).to eq expected_url
    end
    it 'returns the url with default subauthority when NOT specified' do
      expected_url = 'http://localhost/test_default/search?subauth=search_sub1_name&query=Smith&param1=delta&param2=echo'
      expect(full_config.url_with_replacements('Smith')).to eq expected_url
    end
    it 'returns the url with subauthority substitution when specified' do
      expected_url = 'http://localhost/test_default/search?subauth=search_sub3_name&query=Smith&param1=delta&param2=echo'
      expect(full_config.url_with_replacements('Smith', 'search_sub3_key')).to eq expected_url
    end
    it 'returns the url with default values when replacements are NOT specified' do
      expected_url = 'http://localhost/test_default/search?subauth=search_sub1_name&query=Smith&param1=delta&param2=echo'
      expect(full_config.url_with_replacements('Smith')).to eq expected_url
    end
    it 'returns the url with replacement substitution values when replacements are specified' do
      expected_url = 'http://localhost/test_default/search?subauth=search_sub1_name&query=Smith&param1=golf&param2=hotel'
      expect(full_config.url_with_replacements('Smith', nil, param1: 'golf', param2: 'hotel')).to eq expected_url
    end

    context 'when subauthorities are not defined' do
      it 'returns the url with query substitution applied' do
        expected_url = 'http://localhost/test_default/search?query=Smith'
        expect(min_config.url_with_replacements('Smith')).to eq expected_url
      end
      it 'and subauth param is included returns the url with query substitution applied ignoring the subauth' do
        expected_url = 'http://localhost/test_default/search?query=Smith'
        expect(min_config.url_with_replacements('Smith', 'fake_subauth_key')).to eq expected_url
      end
    end

    context 'when replacements are not defined' do
      it 'returns the url with query substitution applied' do
        expected_url = 'http://localhost/test_default/search?query=Smith'
        expect(min_config.url_with_replacements('Smith')).to eq expected_url
      end
      it 'and replacements param is included returns the url with query substitution applied ignoring the replacements' do
        expected_url = 'http://localhost/test_default/search?query=Smith'
        expect(min_config.url_with_replacements('Smith', nil, fake_replacement_key: 'fake_value')).to eq expected_url
      end
    end
  end
end
