require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::ActionConfig do
  before do
    Qa::LinkedData::AuthorityRegistryService.empty
  end

  let!(:full_search_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_FULL_CONFIG).search_config }
  let(:min_search_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_MIN_CONFIG).search_config }
  let(:term_only_search_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_TERM_ONLY_CONFIG).search_config }

  describe 'model attributes' do
    subject { full_search_config }

    it { is_expected.to respond_to :url_config }
    it { is_expected.to respond_to :results_map }
    it { is_expected.to respond_to :subauth_map }
    it { is_expected.to respond_to :subauth_variable }
    it { is_expected.to respond_to :action_request_variable }
    it { is_expected.to respond_to :default_language }
  end

  describe '#initialize' do
    context 'when missing iri template' do
      let(:config) do
        { results: { id: 'foo' } }
      end

      it 'raises an error' do
        expect { described_class.new(config) }.to raise_error(Qa::InvalidConfiguration, 'iri template is required')
      end
    end

    context 'when all required components present' do
      before do
        allow(Qa::IriTemplate::UrlConfig).to receive(:new).and_return(instance_double("template"))
        allow(Qa::LinkedData::Config::ResultsMap).to receive(:new).and_return(instance_double("results_map"))
      end
      let(:config) do
        {
          url: { template: 'foo' },
          results: { id: 'foo' }
        }
      end

      it 'does not raise an error' do
        expect { described_class.new(config) }.not_to raise_error
      end
    end
  end

  describe '#iri_template' do
    it 'returns an instance of iri_template' do
      expect(full_search_config.url_config).to be_kind_of Qa::IriTemplate::UrlConfig
    end
  end

  describe '#subauth_map' do
    it 'returns an instance of subauth_map' do
      expect(full_search_config.subauth_map).to be_kind_of Qa::LinkedData::Config::SubauthMap
    end
  end

  describe '#subauth' do
    it 'returns the name of the template variable that is controlled by the subauth_map' do
      expect(full_search_config.subauth_variable).to eq 'subauth'
    end
  end

  describe '#language' do
    it 'returns list of language codes' do
      expect(full_search_config.default_language).to match_array ['en', 'fr', 'de']
    end
  end

  describe '#term?' do
    before do
      allow(Qa::IriTemplate::UrlConfig).to receive(:new).and_return(instance_double("template"))
      allow(Qa::LinkedData::Config::ResultsMap).to receive(:new).and_return(instance_double("results_map"))
    end
    let(:config) do
      {
          url: { template: 'foo' },
          results: { id: 'foo' }
      }
    end

    it 'returns false' do
      expect(described_class.new(config).term?).to eq false
    end
  end

  describe '#search?' do
    before do
      allow(Qa::IriTemplate::UrlConfig).to receive(:new).and_return(instance_double("template"))
      allow(Qa::LinkedData::Config::ResultsMap).to receive(:new).and_return(instance_double("results_map"))
    end
    let(:config) do
      {
          url: { template: 'foo' },
          results: { id: 'foo' }
      }
    end

    it 'returns false' do
      expect(described_class.new(config).search?).to eq false
    end
  end
end
