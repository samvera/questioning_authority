require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::TermResultsMap do
  let(:results_map_config) do
    {
      id_predicate: 'http://purl.org/dc/terms/identifier',
      label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
      altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
      broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader',
      narrower_predicate: 'http://www.w3.org/2004/02/skos/core#narrower',
      sameas_predicate: 'http://www.w3.org/2004/02/skos/core#exactMatch',
      extra_predicate: 'WILL BE IGNORED',
      sort_predicate: 'http://vivoweb.org/ontology/core#rank' # applicable for search but not term, will be ignored
    }
  end

  subject { described_class.new(results_map_config) }

  describe '#predicate_map' do
    context 'with all predicates mapped' do
      let(:expected_map) do
        {
          uri: :subject_uri,
          id: 'http://purl.org/dc/terms/identifier',
          label: 'http://www.w3.org/2004/02/skos/core#prefLabel',
          altlabel: 'http://www.w3.org/2004/02/skos/core#altLabel',
          broader: 'http://www.w3.org/2004/02/skos/core#broader',
          narrower: 'http://www.w3.org/2004/02/skos/core#narrower',
          sameas: 'http://www.w3.org/2004/02/skos/core#exactMatch'
        }
      end

      it 'includes all predicates in the results map' do
        expect(subject.predicate_map).to eq expected_map
      end
    end

    context 'with min set of predicates mapped' do
      let(:results_map_config) do
        {
          label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
          extra_predicate: 'WILL BE IGNORED'
        }
      end
      let(:expected_map) do
        {
          uri: :subject_uri,
          id: :subject_uri,
          label: 'http://www.w3.org/2004/02/skos/core#prefLabel'
        }
      end

      it 'includes min and default predicates in the results map' do
        expect(subject.predicate_map).to eq expected_map
      end
    end
  end

  describe '#predicates' do
    context 'with all predicates mapped' do
      let(:expected_predicates) do
        [
          'http://purl.org/dc/terms/identifier',
          'http://www.w3.org/2004/02/skos/core#prefLabel',
          'http://www.w3.org/2004/02/skos/core#altLabel',
          'http://www.w3.org/2004/02/skos/core#broader',
          'http://www.w3.org/2004/02/skos/core#narrower',
          'http://www.w3.org/2004/02/skos/core#exactMatch'
        ]
      end

      it 'returns all term predicates removing unknown predicates' do
        expect(subject.predicates).to match_array expected_predicates
      end
    end

    context 'with min set of predicates mapped' do
      let(:results_map_config) do
        {
          label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
          extra_predicate: 'WILL BE IGNORED'
        }
      end
      let(:expected_predicates) { ['http://www.w3.org/2004/02/skos/core#prefLabel'] }

      it 'includes min and default predicates in the results map' do
        expect(subject.predicates).to match_array expected_predicates
      end
    end
  end
end
