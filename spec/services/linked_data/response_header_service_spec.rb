require 'spec_helper'

RSpec.describe Qa::LinkedData::ResponseHeaderService do
  let(:request) { double }

  describe '#search_header' do
    let(:request_header) do
      {
        replacements:
        {
          'startRecord' => '2',
          'maxRecords' => '10'
        }
      }.with_indifferent_access
    end
    let(:search_config) { double }
    let(:graph) { instance_double(RDF::Graph) }
    let(:results) { instance_double(Array) }
    let(:ldpath_program) { instance_double(Ldpath::Program) }
    let(:service_uri) { instance_double(String) }
    let(:ldpath) { search_config.total_count_ldpath }
    let(:prefixes) do
      { "vivo" => "http://vivoweb.org/ontology/core#" }
    end

    context 'when config defines pagination params' do
      before do
        allow(search_config).to receive(:start_record_parameter).and_return('startRecord')
        allow(search_config).to receive(:requested_records_parameter).and_return('maxRecords')
        allow(search_config).to receive(:total_count_ldpath).and_return('vivo::count')
        allow(search_config).to receive(:prefixes).and_return(prefixes)
        allow(search_config).to receive(:service_uri).and_return(service_uri)
        allow(results).to receive(:count).and_return(10)
        allow(Qa::LinkedData::LdpathService).to receive(:ldpath_program)
          .with(ldpath:, prefixes: search_config.prefixes).and_return(ldpath_program)
        allow(Qa::LinkedData::LdpathService).to receive(:ldpath_evaluate)
          .with(program: ldpath_program, graph:, subject_uri: anything).and_return(['134'])
      end

      it 'gets pagination data from request header' do
        expected_results =
          {
            start_record: 2,
            requested_records: 10,
            retrieved_records: 10,
            total_records: 134
          }
        expect(described_class.new(request_header:, results:, config: search_config, graph:).search_header).to eq expected_results
      end
    end

    context 'when config does not define pagination params' do
      before do
        allow(search_config).to receive(:start_record_parameter).and_return(nil)
        allow(search_config).to receive(:requested_records_parameter).and_return(nil)
        allow(search_config).to receive(:total_count_ldpath).and_return(nil)
        allow(search_config).to receive(:prefixes).and_return(nil)
        allow(search_config).to receive(:service_uri).and_return(nil)
        allow(results).to receive(:count).and_return(10)
      end

      it 'returns defaults' do
        expected_results =
          {
            start_record: 1,
            requested_records: "DEFAULT",
            retrieved_records: 10,
            total_records: "NOT REPORTED"
          }
        expect(described_class.new(request_header:, results:, config: search_config, graph:).search_header).to eq expected_results
      end
    end
  end

  describe '#fetch_header' do
    let(:request_header) do
      {
      }.with_indifferent_access
    end
    let(:term_config) { double }
    let(:graph) { instance_double(RDF::Graph) }
    let(:results) { instance_double(Hash) }

    context 'when config defines pagination params' do
      before do
        allow(results).to receive(:[]).with('predicates').and_return('pred1' => 'val1', 'pred2' => 'val2')
      end

      it 'gets pagination data from request header' do
        expected_results =
          {
            predicate_count: 2
          }
        expect(described_class.new(request_header:, results:, config: term_config, graph:).fetch_header).to eq expected_results
      end
    end

    context 'when config does not define pagination params' do
      before do
        allow(results).to receive(:[]).with('predicates').and_return(nil)
      end

      it 'returns defaults' do
        expected_results =
          {
            predicate_count: 0
          }
        expect(described_class.new(request_header:, results:, config: term_config, graph:).fetch_header).to eq expected_results
      end
    end
  end
end
