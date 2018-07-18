require 'spec_helper'

describe Qa::Authorities::LinkedData::TermConfig do
  let(:full_config) { Qa::Authorities::LinkedData::Config.new(:LOD_FULL_CONFIG).term }
  let(:min_config) { Qa::Authorities::LinkedData::Config.new(:LOD_MIN_CONFIG).term }
  let(:search_only_config) { Qa::Authorities::LinkedData::Config.new(:LOD_SEARCH_ONLY_CONFIG).term }
  let(:encoding_config) { Qa::Authorities::LinkedData::Config.new(:LOD_ENCODING_CONFIG).term }

  describe '#term_config' do
    let(:full_term_config) do
      {
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

  describe '#term_url' do
    let(:url_config) do
      {
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
      }
    end

    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_url).to eq nil
    end
    it 'returns the term url from the configuration' do
      expect(full_config.term_url).to eq url_config
    end
  end

  describe '#term_url' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_url_template).to eq nil
    end
    it 'returns the term url from the configuration' do
      expected_url = 'http://localhost/test_default/term/{?subauth}/{?term_id}?param1={?param1}&param2={?param2}'
      expect(full_config.term_url_template).to eq expected_url
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
      expect(full_config.term_language).to eq [:en]
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

  describe '#term_results_label_predicate' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_results_label_predicate).to eq nil
    end
    it 'returns the predicate that holds the label in term results' do
      expect(full_config.term_results_label_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#prefLabel')
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

  describe '#term_replacements?' do
    it 'returns false if only search configuration is defined' do
      expect(search_only_config.term_replacements?).to eq false
    end
    it 'returns false if the configuration does NOT define replacements' do
      expect(min_config.term_replacements?).to eq false
    end
    it 'returns true if the configuration defines replacements' do
      expect(full_config.term_replacements?).to eq true
    end
  end

  describe '#term_replacement_count' do
    it 'returns 0 if only search configuration is defined' do
      expect(search_only_config.term_replacement_count).to eq 0
    end
    it 'returns 0 if replacement_count is NOT defined' do
      expect(min_config.term_replacement_count).to eq 0
    end
    it 'returns the number of replacements if defined' do
      expect(full_config.term_replacement_count).to eq 2
    end
  end

  describe '#term_replacements' do
    it 'returns empty hash if only search configuration is defined' do
      empty_hash = {}
      expect(search_only_config.term_replacements).to eq empty_hash
    end
    it 'returns empty hash if no replacement patterns are defined' do
      empty_hash = {}
      expect(min_config.term_replacements).to eq empty_hash
    end
    it 'returns hash of all replacement patterns' do
      expected_hash = {
        param1: { :@type => 'IriTemplateMapping', variable: 'param1', property: 'hydra:freetextQuery', required: false, default: 'alpha' },
        param2: { :@type => 'IriTemplateMapping', variable: 'param2', property: 'hydra:freetextQuery', required: false, default: 'beta' }
      }
      expect(full_config.term_replacements).to eq expected_hash
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

  describe '#term_subauthority_replacement_pattern' do
    it 'returns empty hash if only search configuration is defined' do
      empty_hash = {}
      expect(search_only_config.term_subauthority_replacement_pattern).to eq empty_hash
    end
    it 'returns empty hash if no subauthorities are defined' do
      empty_hash = {}
      expect(min_config.term_subauthority_replacement_pattern).to eq empty_hash
    end
    it 'returns hash replacement pattern for subauthority and the default value' do
      expected_hash = { pattern: 'subauth', default: 'term_sub2_name' }
      expect(full_config.term_subauthority_replacement_pattern).to eq expected_hash
    end
  end

  # rubocop:disable RSpec/RepeatedExample
  describe '#term_url_with_replacements' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_url_with_replacements('C123')).to eq nil
    end
    context 'when subauthorities ARE defined' do
      it 'returns the url with query substitution applied' do
        expected_url = 'http://localhost/test_default/term/term_sub2_name/C123?param1=alpha&param2=beta'
        expect(full_config.term_url_with_replacements('C123')).to eq expected_url
      end
      it 'returns the url with default subauthority when NOT specified' do
        expected_url = 'http://localhost/test_default/term/term_sub2_name/C123?param1=alpha&param2=beta'
        expect(full_config.term_url_with_replacements('C123')).to eq expected_url
      end
      it 'returns the url with subauthority substitution when specified' do
        expected_url = 'http://localhost/test_default/term/term_sub3_name/C123?param1=alpha&param2=beta'
        expect(full_config.term_url_with_replacements('C123', 'term_sub3_key')).to eq expected_url
      end
      it 'returns the url with default values when replacements are NOT specified' do
        expected_url = 'http://localhost/test_default/term/term_sub2_name/C123?param1=alpha&param2=beta'
        expect(full_config.term_url_with_replacements('C123')).to eq expected_url
      end
      it 'returns the url with replacement substitution values when replacements are specified' do
        expected_url = 'http://localhost/test_default/term/term_sub2_name/C123?param1=golf&param2=hotel'
        expect(full_config.term_url_with_replacements('C123', nil, param1: 'golf', param2: 'hotel')).to eq expected_url
      end
    end

    context 'when subauthorities are NOT defined' do
      it 'returns the url with query substitution applied' do
        expected_url = 'http://localhost/test_default/term/C123'
        expect(min_config.term_url_with_replacements('C123')).to eq expected_url
      end
      it 'and subauth param is included returns the url with query substitution applied ignoring the subauth' do
        expected_url = 'http://localhost/test_default/term/C123'
        expect(min_config.term_url_with_replacements('C123', 'fake_subauth_key')).to eq expected_url
      end
    end

    context 'when replacements are not defined' do
      it 'returns the url with query substitution applied' do
        expected_url = 'http://localhost/test_default/term/C123'
        expect(min_config.term_url_with_replacements('C123')).to eq expected_url
      end
      it 'and replacements param is included returns the url with query substitution applied ignoring the replacements' do
        expected_url = 'http://localhost/test_default/term/C123'
        expect(min_config.term_url_with_replacements('C123', nil, fake_replacement_key: 'fake_value')).to eq expected_url
      end
    end

    context 'with encoding specified in config' do
      it 'returns the uri as the url' do
        expected_url = 'http://localhost/test_default/term?uri=http%3A%2F%2Fencoded%2Ebecause%3Fencode%3Dtrue&yes%3Aencoded%20here&no:encoding here&defaults:to not encoded'
        term_uri = 'http://encoded.because?encode=true'
        replacements = { encode_true: 'yes:encoded here', encode_false: 'no:encoding here', encode_not_specified: 'defaults:to not encoded' }
        expect(encoding_config.term_url_with_replacements(term_uri, nil, replacements)).to eq expected_url
      end
    end
  end
  # rubocop:enable RSpec/RepeatedExample
end
