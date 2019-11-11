require 'spec_helper'

RSpec.describe Qa::LinkedData::LdpathService do
  let(:ldpath) { 'skos:prefLabel ::xsd:string' }

  describe '.ldpath_program' do
    subject { described_class.ldpath_program(ldpath: ldpath, prefixes: prefixes) }

    let(:prefixes) do
      { skos: 'http://www.w3.org/2004/02/skos/core#' }
    end

    it 'returns instance of Ldpath::Program' do
      expect(subject).to be_kind_of Ldpath::Program
    end

    context 'when ldpath_program gets parse error' do
      let(:cause) { "undefined method `ascii_tree' for nil:NilClass" }
      let(:warning) { I18n.t('qa.linked_data.ldpath.parse_logger_error') }
      let(:program_code) { "BAD_PROGRAM ;" }
      let(:log_message) { "WARNING: #{warning}... cause: #{cause}\n   ldpath_program=\n#{program_code}" }

      before do
        allow(described_class).to receive(:ldpath_program_code).with(anything).and_return(program_code)
        allow(Ldpath::Program).to receive(:parse).with(anything).and_raise(cause)
      end

      it 'logs error and returns PARSE ERROR as the value' do
        expect(Rails.logger).to receive(:warn).with(log_message)
        expect { subject.values(graph, subject_uri) }.to raise_error StandardError, I18n.t('qa.linked_data.ldpath.parse_error') + "... cause: #{cause}"
      end
    end
  end

  describe '.ldpath_program_code' do
    subject { described_class.ldpath_program_code(ldpath: ldpath, prefixes: prefixes, languages: languages) }

    context 'for a ldpath without language pattern' do
      let(:ldpath) { 'dcterms:identifier' }
      let(:languages) { [:fr] }
      let(:prefixes) { { "dcterms" => "http://purl.org/dc/terms/" } }
      it 'generates the simple program code' do
        expected_program = <<-PROGRAM
@prefix dcterms : <http://purl.org/dc/terms/> \;
property = dcterms:identifier \;
PROGRAM
        expect(subject).to eq expected_program
      end
    end

    context 'for a ldpath with language pattern' do
      let(:ldpath) { 'madsrdf:authoritativeLabel*LANG* ::xsd:string' }
      let(:prefixes) { { "madsrdf" => "http://www.loc.gov/mads/rdf/v1#" } }
      context 'and no languages specified' do
        let(:languages) { nil }
        it 'generates the simple program code' do
          expected_program = <<-PROGRAM
@prefix madsrdf : <http://www.loc.gov/mads/rdf/v1#> \;
property = madsrdf:authoritativeLabel ::xsd:string \;
PROGRAM
          expect(subject).to eq expected_program
        end
      end

      context 'and one language specified' do
        let(:languages) { [:en] }
        it 'generates a program with the language' do
          expected_program = <<-PROGRAM
@prefix madsrdf : <http://www.loc.gov/mads/rdf/v1#> \;
en_property = madsrdf:authoritativeLabel[@en] ::xsd:string \;
property = madsrdf:authoritativeLabel[@none] ::xsd:string \;
PROGRAM
          expect(subject).to eq expected_program
        end
      end

      context 'and multiple languages specified' do
        let(:languages) { [:fr, :de] }
        it 'generates a program with languages' do
          expected_program = <<-PROGRAM
@prefix madsrdf : <http://www.loc.gov/mads/rdf/v1#> \;
fr_property = madsrdf:authoritativeLabel[@fr] ::xsd:string \;
de_property = madsrdf:authoritativeLabel[@de] ::xsd:string \;
property = madsrdf:authoritativeLabel[@none] ::xsd:string \;
PROGRAM
          expect(subject).to eq expected_program
        end
      end
    end
  end

  describe '.ldpath_evaluate' do
    subject { described_class.ldpath_evaluate(program: program, graph: graph, subject_uri: subject_uri) }

    let(:program) { instance_double(Ldpath::Program) }
    let(:graph) { instance_double(RDF::Graph) }
    let(:subject_uri) { instance_double(RDF::URI) }

    before do
      allow(Ldpath::Program).to receive(:parse).with(anything).and_return(program)
    end

    context 'when program does not contain languages' do
      context 'and value is a string' do
        let(:values) { ['value'] }
        before do
          allow(program).to receive(:evaluate)
            .with(subject_uri, context: graph, limit_to_context: true)
            .and_return('property' => values)
        end
        it 'returns the string values as is' do
          expected_values = values.map { |v| RDF::Literal.new(v) }
          expect(subject).to match_array expected_values
        end
      end

      context 'and value is a URI' do
        let(:values) { [RDF::URI.new('http://example.com/1'), RDF::URI.new('http://example.com/2')] }
        before do
          allow(program).to receive(:evaluate)
            .with(subject_uri, context: graph, limit_to_context: true)
            .and_return('property' => values)
        end
        it 'returns the URIs' do
          expected_values = values
          expect(subject).to match_array expected_values
        end
      end

      context 'and value is numeric' do
        let(:values) { [23, 14, 55] }
        before do
          allow(program).to receive(:evaluate)
            .with(subject_uri, context: graph, limit_to_context: true)
            .and_return('property' => values)
        end
        it 'returns the URIs' do
          expected_values = values
          expect(subject).to match_array expected_values
        end
      end
    end

    context 'when program has languages' do
      context 'and one language specified' do
        let(:en_values) { ['en_value'] }
        let(:untagged_values) { ['untagged_value'] }
        before do
          allow(program).to receive(:evaluate)
            .with(subject_uri, context: graph, limit_to_context: true)
            .and_return('en_property' => en_values, 'property' => untagged_values)
        end
        it 'generates a program with the language' do
          expected_values =
            en_values.map { |v| RDF::Literal.new(v, language: :en) } +
            untagged_values.map { |v| RDF::Literal.new(v) }
          expect(subject).to match_array expected_values
        end
      end

      context 'and multiple languages specified' do
        let(:fr_values) { ['fr_value1', 'fr_value2', 'fr_value1'] }
        let(:de_values) { ['de_value'] }
        let(:untagged_values) { ['untagged_value'] }
        before do
          allow(program).to receive(:evaluate)
            .with(subject_uri, context: graph, limit_to_context: true)
            .and_return('fr_property' => fr_values, 'de_property' => de_values, 'property' => untagged_values)
        end
        it 'returns the extracted label' do
          expected_values =
            (fr_values.uniq.map { |v| RDF::Literal.new(v, language: :fr) } +
             de_values.map { |v| RDF::Literal.new(v, language: :de) } +
             untagged_values.map { |v| RDF::Literal.new(v) }).uniq
          expect(subject).to match_array expected_values
        end
      end
    end

    context 'when ldpath_evaluate gets parse error' do
      let(:cause) { "unknown cause" }
      let(:warning) { I18n.t('qa.linked_data.ldpath.evaluate_logger_error') }
      let(:log_message) { "WARNING: #{warning} (cause: #{cause}" }

      before { allow(program).to receive(:evaluate).with(subject_uri, context: graph, limit_to_context: true).and_raise(ParseError, cause) }

      it 'logs error and returns PARSE ERROR as the value' do
        expect(Rails.logger).to receive(:warn).with(log_message)
        expect { subject }.to raise_error ParseError, I18n.t('qa.linked_data.ldpath.evaluate_error') + "... cause: #{cause}"
      end
    end

    context 'when program is empty' do
      let(:program) { nil }
      it 'returns empty array' do
        expect { subject }.to raise_error ArgumentError, "You must specify a program when calling ldpath_evaluate"
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
