require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::ResultsMap do
  describe 'model attributes' do
    subject { described_class.instance_methods }

    it { is_expected.to include :predicates }
    it { is_expected.to include :predicate_map }
  end

  describe '#initialize' do
    context 'when missing label_predicate' do
      let(:results_map_config) do
        {
          id_predicate: 'http://purl.org/dc/terms/identifier',
          sort_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel'
        }
      end

      it 'raises an error' do
        expect { described_class.new(results_map_config) }.to raise_error(ArgumentError, 'label_predicate is required')
      end
    end
  end

  describe 'inheriting class' do
    let(:results_map_config) do
      {
        label_predicate: 'http://www.w3.org/2004/02/skos/core#prefLabel'
      }
    end

    context 'when #extract_map is not defined' do
      class NoExtractMapResultsMap < described_class
        # fails to define extract_map abstract methods

        def extract_predicates_list
          []
        end
      end

      it 'raises an error because extract_map is an abstract method' do
        expect { NoExtractMapResultsMap.new(results_map_config) }.to raise_error(NoMethodError, 'extract_map is an abstract method and must be implemented by a concrete subclass')
      end
    end

    context 'when #extract_predicates_list is not defined' do
      class NoExtractPredicatesListResultsMap < described_class
        # fails to define extract_predicates_list abstract methods

        def extract_map
          {}
        end
      end

      it 'raises an error because extract_predicates_list is an abstract method' do
        expect { NoExtractPredicatesListResultsMap.new(results_map_config) }.to raise_error(NoMethodError, 'extract_predicates_list is an abstract method and must be implemented by a concrete subclass')
      end
    end
  end
end
