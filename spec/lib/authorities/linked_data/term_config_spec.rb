require 'spec_helper'

describe Qa::Authorities::LinkedData::Config do
  let(:full_config) { described_class.new(:LOD_FULL_CONFIG) }
  let(:min_config) { described_class.new(:LOD_MIN_CONFIG) }
  let(:search_only_config) { described_class.new(:LOD_SEARCH_ONLY_CONFIG) }

  describe '#term_config' do
    let(:full_term_config) do
      {
        'url' => 'http://localhost/test_default/term/__TERM_SUB_AUTH__/__TERM_ID__&param1=__TERM_REP_PARAM1__&param2=__TERM_REP_PARAM2__',
        'term_id' => 'ID',
        'language' => 'en',
        'replacement_count' => 2,
        'replacement_1' => { 'param' => 'term_param1', 'pattern' => '__TERM_REP_PARAM1__', 'default' => 'alpha' },
        'replacement_2' => { 'param' => 'term_param2', 'pattern' => '__TERM_REP_PARAM2__', 'default' => 'beta' },
        'results' => {
          'id_predicate' => 'http://purl.org/dc/terms/identifier',
          'label_predicate' => 'http://www.w3.org/2004/02/skos/core#prefLabel',
          'altlabel_predicate' => 'http://www.w3.org/2004/02/skos/core#altLabel',
          'broader_predicate' => 'http://www.w3.org/2004/02/skos/core#broader',
          'narrower_predicate' => 'http://www.w3.org/2004/02/skos/core#narrower',
          'sameas_predicate' => 'http://schema.org/sameAs'
        },
        'subauthorities' => {
          'replacement' => { 'pattern' => '__TERM_SUB_AUTH__', 'default' => 'term_sub1_name' },
          'term_sub1_key' => 'term_sub1_name',
          'term_sub2_key' => 'term_sub2_name', 'term_sub3_key' => 'term_sub3_name'
        }
      }
    end

    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_config).to eq nil
    end
    it 'returns hash of term configuration' do
      expect(full_config.term_config).to eq full_term_config
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
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_url).to eq nil
    end
    it 'returns the term url from the configuration' do
      expected_url = 'http://localhost/test_default/term/__TERM_SUB_AUTH__/__TERM_ID__&param1=__TERM_REP_PARAM1__&param2=__TERM_REP_PARAM2__'
      expect(full_config.term_url).to eq expected_url
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
      expect(full_config.term_results_sameas_predicate).to eq RDF::URI('http://schema.org/sameAs')
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
        'term_param1' => { pattern: '__TERM_REP_PARAM1__', default: 'alpha' },
        'term_param2' => { pattern: '__TERM_REP_PARAM2__', default: 'beta' }
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
        'term_sub1_key' => 'term_sub1_name',
        'term_sub2_key' => 'term_sub2_name',
        'term_sub3_key' => 'term_sub3_name'
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
      expected_hash = { pattern: '__TERM_SUB_AUTH__', default: 'term_sub1_name' }
      expect(full_config.term_subauthority_replacement_pattern).to eq expected_hash
    end
  end

  describe '#term_url_with_replacements' do
    it 'returns nil if only search configuration is defined' do
      expect(search_only_config.term_url_with_replacements('C123')).to eq nil
    end
    it 'returns the url with query substitution applied' do
      expected_url = 'http://localhost/test_default/term/term_sub1_name/C123&param1=alpha&param2=beta'
      expect(full_config.term_url_with_replacements('C123')).to eq expected_url
    end
    it 'returns the url with default subauthority when NOT specified' do
      expected_url = 'http://localhost/test_default/term/term_sub1_name/C123&param1=alpha&param2=beta'
      expect(full_config.term_url_with_replacements('C123')).to eq expected_url
    end
    it 'returns the url with subauthority substitution when specified' do
      expected_url = 'http://localhost/test_default/term/term_sub3_name/C123&param1=alpha&param2=beta'
      expect(full_config.term_url_with_replacements('C123', 'term_sub3_key')).to eq expected_url
    end
    it 'returns the url with default values when replacements are NOT specified' do
      expected_url = 'http://localhost/test_default/term/term_sub1_name/C123&param1=alpha&param2=beta'
      expect(full_config.term_url_with_replacements('C123')).to eq expected_url
    end
    it 'returns the url with replacement substitution values when replacements are specified' do
      expected_url = 'http://localhost/test_default/term/term_sub1_name/C123&param1=golf&param2=hotel'
      expect(full_config.term_url_with_replacements('C123', nil, 'term_param1' => 'golf', 'term_param2' => 'hotel')).to eq expected_url
    end

    context 'when subauthorities are not defined' do
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
        expect(min_config.term_url_with_replacements('C123', nil, 'fake_replacement_key' => 'fake_value')).to eq expected_url
      end
    end
  end
end
