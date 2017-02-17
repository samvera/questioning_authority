require 'spec_helper'

describe Qa::Authorities::LinkedData::Config do
  let(:full_config) { described_class.new(:LOD_FULL_CONFIG) }
  let(:min_config) { described_class.new(:LOD_MIN_CONFIG) }
  let(:term_only_config) { described_class.new(:LOD_TERM_ONLY_CONFIG) }

  describe '#new' do
    context 'without an authority' do
      it 'raises an exception' do
        expect { described_class.new }.to raise_error ArgumentError, /wrong number of arguments/
      end
    end
    context 'with an invalid authority' do
      it 'raises an exception' do
        expect { described_class.new(:FOO) }.to raise_error Qa::InvalidLinkedDataAuthority, /Unable to initialize linked data authority FOO/
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
        'term' => {
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
        },
        'search' => {
          'url' => 'http://localhost/test_default/search?subauth=__SEARCH_SUB_AUTH__&query=__QUERY__&param1=__SEARCH_REP_PARAM1__&param2=__SEARCH_REP_PARAM2__',
          'language' => ['en', 'fr', 'de'],
          'replacement_count' => 2,
          'replacement_1' => { 'param' => 'search_param1', 'pattern' => '__SEARCH_REP_PARAM1__', 'default' => 'delta' },
          'replacement_2' => { 'param' => 'search_param2', 'pattern' => '__SEARCH_REP_PARAM2__', 'default' => 'echo' },
          'results' => {
            'id_predicate' => 'http://purl.org/dc/terms/identifier',
            'label_predicate' => 'http://www.w3.org/2004/02/skos/core#prefLabel',
            'altlabel_predicate' => 'http://www.w3.org/2004/02/skos/core#altLabel',
            'sort_predicate' => 'http://www.w3.org/2004/02/skos/core#prefLabel'
          },
          'subauthorities' => {
            'replacement' => { 'pattern' => '__SEARCH_SUB_AUTH__', 'default' => 'search_sub1_name' },
            'search_sub1_key' => 'search_sub1_name',
            'search_sub2_key' => 'search_sub2_name', 'search_sub3_key' => 'search_sub3_name'
          }
        }
      }
    end

    it 'returns hash of the full authority configuration' do
      expect(full_config.auth_config).to eq full_auth_config
    end
  end
end
