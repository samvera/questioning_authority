require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::TermConfig do
  before do
    Qa::LinkedData::AuthorityRegistryService.empty
  end

  let!(:full_term_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_FULL_CONFIG).term_config }
  let(:min_term_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_MIN_CONFIG).term_config }
  let(:search_only_term_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_SEARCH_ONLY_CONFIG).term_config }

  describe 'model attributes' do
    subject { full_term_config }

    it { is_expected.to respond_to :results_map }
    it { is_expected.to respond_to :action_request_variable }
  end

  describe '#initialize' do
    context 'when missing results map' do
      before do
        allow(Qa::IriTemplate::UrlConfig).to receive(:new).and_return(instance_double("template"))
      end
      let(:config) do
        { url: { template: 'foo' } }
      end

      it 'raises an error' do
        expect { described_class.new(config) }.to raise_error(Qa::InvalidConfiguration, 'Results map is required')
      end
    end
  end

  describe '#action_request_variable' do
    it 'returns configured name for term_id variable' do
      expect(full_term_config.action_request_variable).to eq 'term_id'
      expect(min_term_config.action_request_variable).to eq 'term_uri'
    end
  end

  describe '#results_map' do
    it 'returns an instance of results_map' do
      expect(full_term_config.results_map).to be_kind_of Qa::LinkedData::Config::ResultsMap
    end
  end

  describe '#supports_term?' do
    it 'returns false if term is NOT configured' do
      expect(search_only_term_config.supports_term?).to eq false
    end
    it 'returns true if term is configured' do
      expect(full_term_config.supports_term?).to eq true
    end
  end
end
