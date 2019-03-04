require 'spec_helper'

RSpec.describe Qa::LinkedData::Mapper::ContextMapperService do
  subject { described_class.map_context(graph: graph, context_map: context_map, subject_uri: subject_uri) }

  let(:graph) { instance_double(RDF::Graph) }
  let(:context_map) { instance_double(Qa::LinkedData::Config::ContextMap) }
  let(:subject_uri) { instance_double(RDF::URI) }

  let(:context_properties) { [birth_date_property_map, death_date_property_map, occupation_property_map] }

  let(:birth_date_property_map) { instance_double(Qa::LinkedData::Config::ContextPropertyMap) }
  let(:death_date_property_map) { instance_double(Qa::LinkedData::Config::ContextPropertyMap) }
  let(:occupation_property_map) { instance_double(Qa::LinkedData::Config::ContextPropertyMap) }

  let(:group_id) { 'dates' }

  let(:birth_date_values) { ['10/15/1943'] }
  let(:death_date_values) { ['12/17/2018'] }
  let(:occupation_values) { ['Actress', 'Director', 'Producer'] }

  before do
    allow(context_map).to receive(:properties).and_return(context_properties)
    allow(context_map).to receive(:group_label).with('dates').and_return('Dates')

    allow(birth_date_property_map).to receive(:label).and_return('Birth')
    allow(birth_date_property_map).to receive(:values).with(graph, subject_uri).and_return(birth_date_values)
    allow(birth_date_property_map).to receive(:group?).and_return(false)
    allow(birth_date_property_map).to receive(:selectable?).and_return(false)
    allow(birth_date_property_map).to receive(:drillable?).and_return(false)
    allow(birth_date_property_map).to receive(:expand_uri?).and_return(false)

    allow(death_date_property_map).to receive(:label).and_return('Death')
    allow(death_date_property_map).to receive(:values).with(graph, subject_uri).and_return(death_date_values)
    allow(death_date_property_map).to receive(:group?).and_return(false)
    allow(death_date_property_map).to receive(:selectable?).and_return(false)
    allow(death_date_property_map).to receive(:drillable?).and_return(false)
    allow(death_date_property_map).to receive(:expand_uri?).and_return(false)

    allow(occupation_property_map).to receive(:label).and_return('Occupation')
    allow(occupation_property_map).to receive(:values).with(graph, subject_uri).and_return(occupation_values)
    allow(occupation_property_map).to receive(:group?).and_return(false)
    allow(occupation_property_map).to receive(:selectable?).and_return(false)
    allow(occupation_property_map).to receive(:drillable?).and_return(false)
    allow(occupation_property_map).to receive(:expand_uri?).and_return(false)
  end

  describe '.map_context' do
    it 'sets the property labels from the property map' do
      find_property_to_test(subject, 'Birth')
      find_property_to_test(subject, 'Death')
      find_property_to_test(subject, 'Occupation')
      expect(subject.size).to be 3
    end

    it 'sets the property values from the graph' do
      result = find_property_to_test(subject, 'Birth')
      expect(result['values']).to match_array birth_date_values
      result = find_property_to_test(subject, 'Death')
      expect(result['values']).to match_array death_date_values
      result = find_property_to_test(subject, 'Occupation')
      expect(result['values']).to match_array occupation_values
    end

    context 'when group? is false' do
      before { allow(birth_date_property_map).to receive(:group?).and_return(false) }
      it 'does not include group in results' do
        result = find_property_to_test(subject, 'Birth')
        expect(result.key?('group')).to be false
      end
    end

    context 'when group? is true' do
      before do
        allow(birth_date_property_map).to receive(:group?).and_return(true)
        allow(birth_date_property_map).to receive(:group_id).and_return('dates')
        allow(context_map).to receive(:group_label).with('dates').and_return('Dates')
      end

      it 'includes group in results' do
        result = find_property_to_test(subject, 'Birth')
        expect(result['group']).to eq 'Dates'
      end
    end

    context 'when drillable? is false' do
      before { allow(death_date_property_map).to receive(:drillable?).and_return(false) }
      it 'includes drillable set to false' do
        result = find_property_to_test(subject, 'Death')
        expect(result['drillable']).to be false
      end
    end

    context 'when drillable? is true' do
      before { allow(death_date_property_map).to receive(:drillable?).and_return(true) }
      it 'includes drillable set to true' do
        result = find_property_to_test(subject, 'Death')
        expect(result['drillable']).to be true
      end
    end

    context 'when selectable? is false' do
      before { allow(occupation_property_map).to receive(:selectable?).and_return(false) }
      it 'includes selectable set to false' do
        result = find_property_to_test(subject, 'Occupation')
        expect(result['selectable']).to be false
      end
    end

    context 'when selectable? is true' do
      before { allow(occupation_property_map).to receive(:selectable?).and_return(true) }
      it 'includes selectable set to true' do
        result = find_property_to_test(subject, 'Occupation')
        expect(result['selectable']).to be true
      end
    end

    context 'when error occurs' do
      let(:cause) { I18n.t('qa.linked_data.ldpath.parse_error') }
      before { allow(occupation_property_map).to receive(:values).with(graph, subject_uri).and_raise(cause) }
      it 'includes error message and empty value array' do
        result = find_property_to_test(subject, 'Occupation')
        expect(result.key?('error')).to be true
        expect(result['error']).to eq cause
        expect(result['values']).to match_array([])
      end
    end
  end

  def find_property_to_test(results, label)
    results.each do |r|
      next unless r['property'] == label
      return r
    end
    raise "property (#{label}) to test not found"
  end
end
