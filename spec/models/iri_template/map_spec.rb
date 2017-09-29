require 'spec_helper'

RSpec.describe Qa::IriTemplate::Map do
  let(:map_required) do
    {
      "@type": "IriTemplateMapping",
      "variable": "query",
      "property": "hydra:freetextQuery",
      "required": true
    }
  end

  describe 'model attributes' do
    subject { described_class.new(map_required) }

    it { is_expected.to respond_to :variable }
    it { is_expected.to respond_to :property }
    it { is_expected.to respond_to :required? }
    it { is_expected.to respond_to :default }
  end

  describe '#initialize' do
    context 'when missing template' do
      before do
        allow(map_required).to receive(:fetch).with(:variable, nil).and_return(nil)
      end

      it 'raises an error' do
        expect { described_class.new(map_required) }.to raise_error(ArgumentError, 'variable is required')
      end
    end

    context 'when invalid required value' do
      let(:map) do
        {
          "@type": "IriTemplateMapping",
          "variable": "subauth",
          "property": "hydra:freetextQuery",
          "required": 'BAD VALUE',
          "default": "personal_name"
        }
      end

      it 'raises an error' do
        expect { described_class.new(map) }.to raise_error(ArgumentError, 'required must be true or false')
      end
    end
  end

  subject { described_class.new(map_required) }

  describe '#variable' do
    it 'returns the configured variable' do
      expect(subject.variable).to eq 'query'
    end
  end

  describe '#required' do
    it 'returns whether map variable is required' do
      expect(subject.required?).to be true
    end
  end

  describe '#default' do
    context 'when variable is required' do
      it 'returns blank' do
        expect(subject.default).to be_nil
      end
    end

    context 'when variable is not required' do
      subject { described_class.new(map_optional) }
      let(:map_optional) do
        {
          "@type": "IriTemplateMapping",
          "variable": "subauth",
          "property": "hydra:freetextQuery",
          "required": false,
          "default": "personal_name"
        }
      end

      it 'returns configured default value' do
        expect(subject.default).to eq 'personal_name'
      end
    end
  end
end
