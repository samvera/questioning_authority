require 'spec_helper'

RSpec.describe Qa::LinkedData::LdpathService do
  let(:ldpath) { 'skos:prefLabel ::xsd:string' }

  describe '.ldpath_program' do
    subject { described_class.ldpath_program(ldpath:, prefixes:) }

    let(:prefixes) do
      { skos: 'http://www.w3.org/2004/02/skos/core#' }
    end

    it 'returns instance of Ldpath::Program' do
      expect(subject).to be_kind_of Ldpath::Program
    end

    context 'when ldpath_program gets parse error' do
      let(:cause) { "undefined method `ascii_tree' for nil:NilClass" }
      let(:warning) { I18n.t('qa.linked_data.ldpath.parse_logger_error') }
      let(:program_code) { "@prefix skos : <http://www.w3.org/2004/02/skos/core#> ;\nproperty = skos:prefLabel ::xsd:string ;" }
      let(:log_message) { "WARNING: #{warning}... cause: #{cause}\n   ldpath_program=\n#{program_code}" }

      before { allow(Ldpath::Program).to receive(:parse).with(anything).and_raise(cause) }

      it 'logs error and returns PARSE ERROR as the value' do
        expect(Rails.logger).to receive(:warn).with(log_message)
        expect { subject.values(graph, subject_uri) }.to raise_error StandardError, I18n.t('qa.linked_data.ldpath.parse_error') + "... cause: #{cause}"
      end
    end
  end

  describe '.ldpath_evaluate' do
    subject { described_class.ldpath_evaluate(program:, graph:, subject_uri:) }

    let(:program) { instance_double(Ldpath::Program) }
    let(:graph) { instance_double(RDF::Graph) }
    let(:subject_uri) { instance_double(RDF::URI) }
    let(:values) { ['Expanded Label'] }

    before do
      allow(Ldpath::Program).to receive(:parse).with('property = skos:prefLabel ::xsd:string ;').and_return(program)
      allow(program).to receive(:evaluate).with(subject_uri, context: graph, limit_to_context: true).and_return('property' => values)
    end
    it 'returns the extracted label' do
      expect(subject).to match_array values
    end

    context 'when ldpath_evaluate gets parse error' do
      let(:cause) { "unknown cause" }
      let(:warning) { I18n.t('qa.linked_data.ldpath.evaluate_logger_error') }
      let(:log_message) { "WARNING: #{warning} (cause: #{cause}" }

      before { allow(program).to receive(:evaluate).with(subject_uri, context: graph, limit_to_context: true).and_raise(cause) }

      it 'logs error and returns PARSE ERROR as the value' do
        expect(Rails.logger).to receive(:warn).with(log_message)
        expect { subject.values(graph, subject_uri) }.to raise_error StandardError, I18n.t('qa.linked_data.ldpath.evaluate_error') + "... cause: #{cause}"
      end
    end
  end

  describe '.predefined_prefixes' do
    subject { described_class.predefined_prefixes }
    it 'includes prefixes defined by ldpath' do
      # only checking for a few prefixes as opposed to the entire list since the gem may expand the list
      expect(subject.keys).to include("rdf", "rdfs", "owl", "skos", "dc")
      expect(subject[:rdf]).to be_present
    end
  end
end
