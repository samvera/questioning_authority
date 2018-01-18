require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::SearchConfig do
  before do
    Qa::LinkedData::AuthorityRegistryService.empty
  end

  let!(:full_search_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_FULL_CONFIG).search_config }
  let(:min_search_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_MIN_CONFIG).search_config }
  let(:term_only_search_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_TERM_ONLY_CONFIG).search_config }

  describe 'model attributes' do
    subject { full_search_config }

    it { is_expected.to respond_to :results_map }
    it { is_expected.to respond_to :context_map }
    it { is_expected.to respond_to :action_request_variable }
  end

  describe '#initialize' do
    context 'when missing results map' do
      before do
        allow(Qa::IriTemplate::Template).to receive(:new).and_return(instance_double("template"))
      end
      let(:config) do
        { url: { template: 'foo' } }
      end

      it 'raises an error' do
        expect { described_class.new(config) }.to raise_error(Qa::InvalidConfiguration, 'Results map is required')
      end
    end
  end

  describe '#context_map' do
    xit 'returns an instance of context_map' do
      # TODO: pending implementation of context map
      expect(full_search_config.context_map).to be_kind_of Qa::LinkedData::Config::ContextMap
    end
  end

  describe '#results_map' do
    it 'returns an instance of results_map' do
      expect(full_search_config.results_map).to be_kind_of Qa::LinkedData::Config::ResultsMap
    end
  end

  describe '#action_request_variable' do
    it 'returns configured name for query variable' do
      expect(full_search_config.action_request_variable).to eq 'query'
      expect(min_search_config.action_request_variable).to eq 'q'
    end
  end

  describe '#supports_search?' do
    it 'returns false if search is NOT configured' do
      expect(term_only_search_config.supports_search?).to eq false
    end
    it 'returns true if search is configured' do
      expect(full_search_config.supports_search?).to eq true
    end
  end
end
