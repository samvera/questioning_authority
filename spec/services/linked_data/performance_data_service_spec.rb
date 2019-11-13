require 'spec_helper'

RSpec.describe Qa::LinkedData::PerformanceDataService do
  let(:request) { double }

  describe '.performance_data' do
    context 'when all data passed in' do
      let(:access_time_s) { 0.5 }
      let(:normalize_time_s) { 0.3 }
      let(:graph) { instance_double(RDF::Graph) }
      let(:results) { instance_double(Hash) }

      let(:fetched_size) { 1086 }
      let(:normalized_size) { 1024 }

      before do
        # rubocop:disable RSpec/MessageChain
        allow(results).to receive_message_chain(:to_s, :size).and_return(normalized_size)
        allow(graph).to receive_message_chain(:triples, :to_s, :size).and_return(fetched_size)
        # rubocop:enable RSpec/MessageChain
      end
      it 'uses passed in params' do
        expected_results =
          {
            fetch_time_s: access_time_s,
            normalization_time_s: normalize_time_s,
            fetched_bytes: fetched_size,
            normalized_bytes: normalized_size,
            fetch_bytes_per_s: (fetched_size / access_time_s),
            normalization_bytes_per_s: (normalized_size / normalize_time_s),
            total_time_s: (access_time_s + normalize_time_s)
          }
        expect(described_class.performance_data(access_time_s: access_time_s, normalize_time_s: normalize_time_s, fetched_data_graph: graph, normalized_data: results)).to eq expected_results
      end
    end
  end
end
