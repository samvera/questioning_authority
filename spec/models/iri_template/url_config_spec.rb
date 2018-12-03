require 'spec_helper'

RSpec.describe Qa::IriTemplate::UrlConfig do
  let(:url_template) do
    {
      :"@context" => "http://www.w3.org/ns/hydra/context.jsonld",
      :"@type" => "IriTemplate",
      template: "http://localhost/test_default/search?subauth={?subauth}&query={?query}&param1={?param1}&param2={?param2}",
      variableRepresentation: "BasicRepresentation",
      mapping: [
        {
          :"@type" => "IriTemplateMapping",
          variable: "query",
          property: "hydra:freetextQuery",
          required: true
        },
        {
          :"@type" => "IriTemplateMapping",
          variable: "subauth",
          property: "hydra:freetextQuery",
          required: false,
          default: "search_sub1_name"
        },
        {
          :"@type" => "IriTemplateMapping",
          variable: "param1",
          property: "hydra:freetextQuery",
          required: false,
          default: "delta"
        },
        {
          :"@type" => "IriTemplateMapping",
          variable: "param2",
          property: "hydra:freetextQuery",
          required: false,
          default: "echo"
        }
      ]
    }
  end

  describe 'model attributes' do
    subject { described_class.new(url_template) }

    it { is_expected.to respond_to :template }
    it { is_expected.to respond_to :variable_representation }
    it { is_expected.to respond_to :mapping }
  end

  describe '#initialize' do
    context 'when missing template' do
      before do
        allow(url_template).to receive(:fetch).with(:template, nil).and_return(nil)
      end

      it 'raises an error' do
        expect { described_class.new(url_template) }.to raise_error(Qa::InvalidConfiguration, 'template is required')
      end
    end

    context 'when missing mapping' do
      before do
        allow(url_template).to receive(:fetch).with(:template, nil).and_return("http://localhost/test_default/search?subauth={?subauth}&query={?query}&param1={?param1}&param2={?param2}")
        allow(url_template).to receive(:fetch).with(:mapping, nil).and_return(nil)
      end

      it 'raises an error' do
        expect { described_class.new(url_template) }.to raise_error(Qa::InvalidConfiguration, 'mapping is required')
      end
    end

    context 'when no maps defined' do
      before do
        allow(url_template).to receive(:fetch).with(:template, nil).and_return("http://localhost/test_default/search?subauth={?subauth}&query={?query}&param1={?param1}&param2={?param2}")
        allow(url_template).to receive(:fetch).with(:mapping, nil).and_return([])
      end

      it 'raises an error' do
        expect { described_class.new(url_template) }.to raise_error(Qa::InvalidConfiguration, 'mapping must include at least one map')
      end
    end
  end

  describe '#template' do
    subject { described_class.new(url_template) }

    it 'returns the configured url template' do
      expect(subject.template).to eq 'http://localhost/test_default/search?subauth={?subauth}&query={?query}&param1={?param1}&param2={?param2}'
    end
  end

  describe '#mapping' do
    subject { described_class.new(url_template) }

    it 'returns an array of variable maps' do
      mapping = subject.mapping
      expect(mapping).to be_kind_of Array
      expect(mapping.size).to eq 4
      expect(mapping.first).to be_kind_of Qa::IriTemplate::VariableMap
    end
  end
end
