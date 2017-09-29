require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::TermConfig do
  before do
    Qa::LinkedData::AuthorityRegistryService.empty
  end

  let!(:full_term_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_FULL_CONFIG).term_config }
  let(:min_term_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_MIN_CONFIG).term_config }
  let(:search_only_term_config) { Qa::LinkedData::Config::AuthorityConfig.new(:LOD_SEARCH_ONLY_CONFIG).term_config }

  describe '#supports_term?' do
    it 'returns false if term is NOT configured' do
      expect(search_only_term_config.supports_term?).to eq false
    end
    it 'returns true if term is configured' do
      expect(full_term_config.supports_term?).to eq true
    end
  end

  describe 'model attributes' do
    subject { full_term_config }

    it { is_expected.to respond_to :iri_template }
    it { is_expected.to respond_to :results_map }
    it { is_expected.to respond_to :subauth_map }
    it { is_expected.to respond_to :subauth_variable }
    it { is_expected.to respond_to :default_language }
  end

  describe '#initialize' do
    context 'when missing iri template' do
      let(:config) do
        { results: { id: 'foo' } }
      end

      it 'raises an error' do
        expect { described_class.new(config) }.to raise_error(ArgumentError, 'iri template is required')
      end
    end

    context 'when missing results map' do
      before do
        allow(Qa::IriTemplate::Template).to receive(:new).and_return(instance_double("template"))
      end
      let(:config) do
        { url: { template: 'foo' } }
      end

      it 'raises an error' do
        expect { described_class.new(config) }.to raise_error(ArgumentError, 'results map is required')
      end
    end
  end

  describe '#iri_template' do
    it 'returns an instance of iri_template' do
      expect(full_term_config.iri_template).to be_kind_of Qa::IriTemplate::Template
    end
  end

  describe '#results_map' do
    it 'returns an instance of results_map' do
      expect(full_term_config.results_map).to be_kind_of Qa::LinkedData::Config::ResultsMap
    end
  end

  describe '#subauth_map' do
    it 'returns an instance of subauth_map' do
      expect(full_term_config.subauth_map).to be_kind_of Qa::LinkedData::Config::SubauthMap
    end
  end

  describe '#subauth' do
    it 'returns the name of the template variable that is controlled by the subauth_map' do
      expect(full_term_config.subauth_variable).to eq 'subauth'
    end
  end

  describe '#language' do
    it 'returns list of language codes' do
      expect(full_term_config.default_language).to match_array ['en']
    end
  end
end
