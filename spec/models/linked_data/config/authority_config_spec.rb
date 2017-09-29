require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::AuthorityConfig do
  before do
    Qa::LinkedData::AuthorityRegistryService.empty
  end

  let!(:full_config) { described_class.new(:LOD_FULL_CONFIG) }
  let(:term_only_config) { described_class.new(:LOD_TERM_ONLY_CONFIG) }
  let(:search_only_config) { described_class.new(:LOD_SEARCH_ONLY_CONFIG) }

  describe '#supports_search?' do
    it 'returns false if search is NOT configured' do
      expect(term_only_config.supports_search?).to eq false
    end
    it 'returns true if search is configured' do
      expect(full_config.supports_search?).to eq true
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

  describe 'model attributes' do
    subject { full_config }

    it { is_expected.to respond_to :authority_name }
    it { is_expected.to respond_to :search_config }
    it { is_expected.to respond_to :term_config }
  end

  describe '#authority_name' do
    it 'returns the name of the configured authority' do
      expect(full_config.authority_name).to eq :LOD_FULL_CONFIG
    end
  end

  describe '#search_config' do
    it 'returns an instance of search config' do
      expect(full_config.search_config).to be_kind_of Qa::LinkedData::Config::SearchConfig
    end
  end

  describe '#term_config' do
    it 'returns an instance of term config' do
      expect(full_config.term_config).to be_kind_of Qa::LinkedData::Config::TermConfig
    end
  end
end
