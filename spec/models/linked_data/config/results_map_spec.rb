require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::ResultsMap do
  describe '#initialize' do
    context 'when missing label_predicate' do
      let(:results_map_config) do
        {
          id_predicate: 'http://purl.org/dc/terms/identifier',
          sort_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel'
        }
      end

      it 'raises an error' do
        expect { described_class.new(config: results_map_config, results_type: described_class::TERM_RESULTS_MAP) }.to raise_error(ArgumentError, 'label_predicate is required')
      end
    end

    context 'when invalid results_type' do
      let(:results_map_config) do
        {
          id_predicate: 'http://purl.org/dc/terms/identifier',
          label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
          altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
          sort_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel'
        }
      end

      it 'raises an error' do
        expect { described_class.new(config: results_map_config, results_type: :BAD_TYPE) }.to raise_error(ArgumentError, 'results_type must be TERM_RESULTS_MAP | SEARCH_RESULTS_MAP')
      end
    end
  end

  describe '#generate_map' do
    context 'for search' do
      subject { described_class.new(config: results_map_config, results_type: described_class::SEARCH_RESULTS_MAP) }

      context 'with all predicates mapped' do
        let(:results_map_config) do
          {
            id_predicate: 'http://purl.org/dc/terms/identifier',
            label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
            altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
            sort_predicate: 'http://vivoweb.org/ontology/core#rank',
            extra_predicate: 'WILL BE IGNORED',
            broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader' # applicable for term but not search, will be ignored
          }
        end
        let(:expected_map) do
          {
            uri: :subject_uri,
            id: 'http://purl.org/dc/terms/identifier',
            label: 'http://www.w3.org/2004/02/skos/core#prefLabel',
            altlabel: 'http://www.w3.org/2004/02/skos/core#altLabel',
            sort: 'http://vivoweb.org/ontology/core#rank'
          }
        end

        it 'includes all predicates in the results map' do
          expect(subject.generate_map).to eq expected_map
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
            label: 'http://www.w3.org/2004/02/skos/core#prefLabel',
            sort: 'http://www.w3.org/2004/02/skos/core#prefLabel'
          }
        end

        it 'includes min and default predicates in the results map' do
          expect(subject.generate_map).to eq expected_map
        end
      end
    end

    context 'for term' do
      subject { described_class.new(config: results_map_config, results_type: described_class::TERM_RESULTS_MAP) }

      context 'with all predicates mapped' do
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
          expect(subject.generate_map).to eq expected_map
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
          expect(subject.generate_map).to eq expected_map
        end
      end
    end
  end

  describe '#predicates' do
    context 'for search' do
      subject { described_class.new(config: results_map_config, results_type: described_class::SEARCH_RESULTS_MAP) }

      context 'with all predicates mapped' do
        let(:results_map_config) do
          {
            id_predicate: 'http://purl.org/dc/terms/identifier',
            label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel',
            altlabel_predicate: 'http://www.w3.org/2004/02/skos/core#altLabel',
            sort_predicate: 'http://vivoweb.org/ontology/core#rank',
            extra_predicate: 'WILL BE IGNORED',
            broader_predicate: 'http://www.w3.org/2004/02/skos/core#broader' # applicable for term but not search, will be ignored
          }
        end
        let(:expected_predicates) do
          ['http://purl.org/dc/terms/identifier',
           'http://www.w3.org/2004/02/skos/core#prefLabel',
           'http://www.w3.org/2004/02/skos/core#altLabel',
           'http://vivoweb.org/ontology/core#rank']
        end

        it 'returns all search predicates removing unknown predicates' do
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

        it 'returns only specified search predicates removing unknown predicates' do
          expect(subject.predicates).to match_array expected_predicates
        end
      end
    end

    context 'for term' do
      subject { described_class.new(config: results_map_config, results_type: described_class::TERM_RESULTS_MAP) }

      context 'with all predicates mapped' do
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
          expect(subject.predicates).to eq expected_predicates
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
end
