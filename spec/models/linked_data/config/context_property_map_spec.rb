require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::ContextPropertyMap do
  subject { described_class.new(property_map) }

  let(:property_map) do
    {
      group_id: 'dates',
      property_label_i18n: 'qa.linked_data.authority.locnames_ld4l_cache.birth_date',
      property_label_default: 'default_Birth',
      ldpath: 'madsrdf:identifiesRWO/madsrdf:birthDate/schema:label',
      selectable: false,
      drillable: false,
      expansion_label_ldpath: 'skos:prefLabel ::xsd:string',
      expansion_id_ldpath: 'loc:lccn ::xsd:string'
    }
  end

  let(:prefixes) do
    {
      schema: 'http://www.w3.org/2000/01/rdf-schema#',
      skos: 'http://www.w3.org/2004/02/skos/core#'
    }
  end

  describe '#new' do
    context 'when ldpath is missing' do
      before { property_map.delete(:ldpath) }

      it 'raises an error' do
        expect { subject }.to raise_error(Qa::InvalidConfiguration, 'ldpath is required')
      end
    end

    context 'when invalid selectable value' do
      before { property_map[:selectable] = 'INVALID' }

      it 'raises an error' do
        expect { subject }.to raise_error(Qa::InvalidConfiguration, 'selectable must be true or false')
      end
    end

    context 'when invalid drillable value' do
      before { property_map[:drillable] = 'INVALID' }

      it 'raises an error' do
        expect { subject }.to raise_error(Qa::InvalidConfiguration, 'drillable must be true or false')
      end
    end

    it 'accepts a single parameter for property_map' do
      expect(subject).to be_kind_of described_class
    end

    it 'accepts required property_map parameter and optional prefixes parameter' do
      expect(described_class.new(property_map, prefixes)).to be_kind_of described_class
    end
  end

  describe '#selectable?' do
    context 'when map has selectable: true' do
      before { property_map[:selectable] = true }

      it 'returns true' do
        expect(subject.selectable?).to be true
      end
    end

    context 'when map has selectable: false' do
      before { property_map[:selectable] = false }

      it 'returns false' do
        expect(subject.selectable?).to be false
      end
    end

    context 'when selectable: is not defined in the map' do
      before { property_map.delete(:selectable) }

      it 'returns false' do
        expect(subject.selectable?).to be false
      end
    end
  end

  describe '#drillable?' do
    context 'when map has drillable: true' do
      before { property_map[:drillable] = true }

      it 'returns true' do
        expect(subject.drillable?).to be true
      end
    end

    context 'when map has drillable: false' do
      before { property_map[:drillable] = false }

      it 'returns false' do
        expect(subject.drillable?).to be false
      end
    end

    context 'when drillable: is not defined in the map' do
      before { property_map.delete(:drillable) }

      it 'returns false' do
        expect(subject.drillable?).to be false
      end
    end
  end

  describe '#label' do
    context 'when map defines property_label_i18n key' do
      context 'and i18n translation is defined in locales' do
        before do
          allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.birth_date', default: 'default_Birth').and_return('Birth')
        end

        it 'returns the translated text' do
          expect(subject.label).to eq 'Birth'
        end
      end

      context 'and i18n translation is NOT defined in locales' do
        context 'and default is defined in the map' do
          before do
            allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.birth_date', default: 'default_Birth').and_return('default_Birth')
          end

          it 'returns the default value' do
            expect(subject.label).to eq 'default_Birth'
          end
        end

        context 'and default is NOT defined in the map' do
          before do
            property_map.delete(:property_label_default)
            allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.birth_date', default: nil).and_return(nil)
          end

          it 'returns nil' do
            expect(subject.label).to eq nil
          end
        end
      end
    end

    context 'when map does NOT define property_label_i18n key' do
      before { property_map.delete(:property_label_i18n) }

      context 'and default is defined in map' do
        it 'returns the default value' do
          expect(subject.label).to eq 'default_Birth'
        end
      end

      context 'and default is NOT defined in map' do
        before { property_map.delete(:property_label_default) }

        it 'returns nil' do
          expect(subject.label).to eq nil
        end
      end
    end
  end

  describe '#group_id' do
    context 'when map defines group_id' do
      it 'returns group_id as a symbol' do
        expect(subject.group_id).to eq :dates
      end
    end

    context 'when map does NOT define group_id' do
      before { property_map.delete(:group_id) }

      it 'returns nil' do
        expect(subject.group_id).to eq nil
      end
    end
  end

  describe '#group?' do
    context 'when map defines group_id' do
      it 'returns true' do
        expect(subject.group?).to be true
      end
    end

    context 'when map does NOT define group_id' do
      before { property_map.delete(:group_id) }

      it 'returns false' do
        expect(subject.group?).to be false
      end
    end
  end

  describe '#values' do
    let(:program) { instance_double(Ldpath::Program) }
    let(:coordinates) { '42.4488° N, 76.4763° W' }
    let(:subject_uri) { instance_double(RDF::URI) }
    let(:graph) { instance_double(RDF::Graph) }

    before do
      allow(Ldpath::Program).to receive(:parse).with(anything).and_return(program)
      allow(program).to receive(:evaluate).with(anything, anything).and_return('property' => [coordinates, coordinates, coordinates]) # check that uniq is applied
    end
    it 'returns the values selected from the graph' do
      expect(subject.values(graph, subject_uri)).to match_array coordinates
    end
  end

  describe '#expand_uri?' do
    context 'when map has a value for expansion_label_ldpath' do
      it 'returns true' do
        expect(subject.expand_uri?).to be true
      end
    end

    context 'when map does NOT have a value for expansion_label_ldpath' do
      before { property_map.delete(:expansion_label_ldpath) }

      it 'returns false' do
        expect(subject.expand_uri?).to be false
      end
    end
  end

  describe '#expanded_values' do
    let(:graph) { instance_double(RDF::Graph) }
    let(:subject_uri) { instance_double(RDF::URI) }

    let(:basic_program) { instance_double(Ldpath::Program) }
    let(:expanded_label_program) { instance_double(Ldpath::Program) }
    let(:expanded_id_program) { instance_double(Ldpath::Program) }

    let(:expanded_uri) { instance_double(RDF::URI) }
    let(:expanded_label) { 'A Broader Term' }
    let(:expanded_id) { '123' }

    before do
      allow(Ldpath::Program).to receive(:parse).with('property = madsrdf:identifiesRWO/madsrdf:birthDate/schema:label ;').and_return(basic_program)
      allow(Ldpath::Program).to receive(:parse).with('property = skos:prefLabel ::xsd:string ;').and_return(expanded_label_program)
      allow(Ldpath::Program).to receive(:parse).with('property = loc:lccn ::xsd:string ;').and_return(expanded_id_program)
      allow(basic_program).to receive(:evaluate).with(subject_uri, context: graph, limit_to_context: true).and_return('property' => [expanded_uri])
      allow(expanded_label_program).to receive(:evaluate).with(RDF::URI.new(subject_uri), context: graph, limit_to_context: true).and_return('property' => [expanded_label])
      allow(expanded_id_program).to receive(:evaluate).with(RDF::URI.new(subject_uri), context: graph, limit_to_context: true).and_return('property' => [expanded_id])
    end
    it 'returns the uri, id, label for the expanded uri value' do
      expanded_values = subject.expanded_values(graph, subject_uri).first
      expect(expanded_values).to be_kind_of Hash
      expect(expanded_values[:uri]).to eq expanded_uri
      expect(expanded_values[:id]).to eq expanded_id
      expect(expanded_values[:label]).to eq expanded_label
    end
  end
end
