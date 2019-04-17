require 'spec_helper'

RSpec.describe Qa::IriTemplateService do
  let(:url_template) do
    {
      :'@context' => 'http://www.w3.org/ns/hydra/context.jsonld',
      :'@type' => 'IriTemplate',
      template: 'http://localhost/test_default/search?{?subauth}&{?query}&{?max_records}&{?lang}',
      variableRepresentation: 'BasicRepresentation',
      mapping: [
        {
          :'@type' => 'IriTemplateMapping',
          variable: 'query',
          property: 'hydra:freetextQuery',
          required: true
        },
        {
          :'@type' => 'IriTemplateMapping',
          variable: 'subauth',
          property: 'hydra:freetextQuery',
          required: false
        },
        {
          :'@type' => 'IriTemplateMapping',
          variable: 'max_records',
          property: 'hydra:freetextQuery',
          required: false,
          default: 20
        },
        {
          :'@type' => 'IriTemplateMapping',
          variable: 'lang',
          property: 'hydra:freetextQuery',
          required: false
        }
      ]
    }
  end
  let(:url_config) { Qa::IriTemplate::UrlConfig.new(url_template) }

  describe '.build_url' do
    context 'when all substitutions specified' do
      let(:substitutions) do
        HashWithIndifferentAccess.new(
          query: 'mark twain',
          subauth: 'corporate_names',
          max_records: 10,
          lang: 'fr'
        )
      end

      it 'returns template with substitutions' do
        expected_url = 'http://localhost/test_default/search?subauth=corporate_names&query=mark twain&max_records=10&lang=fr'
        expect(described_class.build_url(url_config: url_config, substitutions: substitutions)).to eq expected_url
      end
    end

    context 'when minimal substitutions specified' do
      context 'and default specified for maxRecords only' do
        let(:substitutions) { HashWithIndifferentAccess.new(query: 'mark twain') }

        it 'returns template with substitutions' do
          expected_url = 'http://localhost/test_default/search?query=mark twain&max_records=20'
          expect(described_class.build_url(url_config: url_config, substitutions: substitutions)).to eq expected_url
        end
      end

      context 'and defaults specified for all' do
        let(:substitutions) { HashWithIndifferentAccess.new(query: 'mark twain') }
        let(:mapping) do
          [
            {
              :'@type' => 'IriTemplateMapping',
              variable: 'query',
              property: 'hydra:freetextQuery',
              required: true
            },
            {
              :'@type' => 'IriTemplateMapping',
              variable: 'subauth',
              property: 'hydra:freetextQuery',
              required: false,
              default: 'personal_names'
            },
            {
              :'@type' => 'IriTemplateMapping',
              variable: 'max_records',
              property: 'hydra:freetextQuery',
              required: false,
              default: 20
            },
            {
              :'@type' => 'IriTemplateMapping',
              variable: 'lang',
              property: 'hydra:freetextQuery',
              required: false,
              default: 'en'
            }
          ]
        end

        before { url_template[:mapping] = mapping }

        it 'returns template with substitutions' do
          expected_url = 'http://localhost/test_default/search?subauth=personal_names&query=mark twain&max_records=20&lang=en'
          expect(described_class.build_url(url_config: url_config, substitutions: substitutions)).to eq expected_url
        end
      end
    end
  end
end
