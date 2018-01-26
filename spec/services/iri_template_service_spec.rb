require 'spec_helper'

RSpec.describe Qa::IriTemplateService do
  let(:url_template) do
    {
      '@context': 'http://www.w3.org/ns/hydra/context.jsonld',
      '@type': 'IriTemplate',
      'template': 'http://localhost/test_default/search?subauth={?subauth}&query={?query}&max_records={?max_records}&language={?language}',
      'variableRepresentation': 'BasicRepresentation',
      'mapping': [
        {
          '@type': 'IriTemplateMapping',
          'variable': 'query',
          'property': 'hydra:freetextQuery',
          'required': true
        },
        {
          '@type': 'IriTemplateMapping',
          'variable': 'subauth',
          'property': 'hydra:freetextQuery',
          'required': false,
          'default': 'personal_names'
        },
        {
          '@type': 'IriTemplateMapping',
          'variable': 'max_records',
          'property': 'hydra:freetextQuery',
          'required': false,
          'default': 20
        },
        {
          '@type': 'IriTemplateMapping',
          'variable': 'language',
          'property': 'hydra:freetextQuery',
          'required': false,
          'default': 'en'
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
          language: 'fr'
        )
      end

      it 'returns template with substitutions' do
        expected_url = 'http://localhost/test_default/search?subauth=corporate_names&query=mark twain&max_records=10&language=fr'
        expect(described_class.build_url(url_config: url_config, substitutions: substitutions)).to eq expected_url
      end
    end

    context 'when minimal substitutions specified' do
      let(:substitutions) { HashWithIndifferentAccess.new(query: 'mark twain') }

      it 'returns template with substitutions' do
        expected_url = 'http://localhost/test_default/search?subauth=personal_names&query=mark twain&max_records=20&language=en'
        expect(described_class.build_url(url_config: url_config, substitutions: substitutions)).to eq expected_url
      end
    end
  end
end
