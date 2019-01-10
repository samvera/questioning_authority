require 'spec_helper'

RSpec.describe Qa::IriTemplate::VariableMap do
  subject { described_class.new(map) }

  let(:map) do
    {
      :"@type" => "IriTemplateMapping",
      property: "hydra:freetextQuery",
      variable: "subauth",
      required: true
    }
  end

  describe 'model attributes' do
    it { is_expected.to respond_to :variable }
    it { is_expected.to respond_to :simple_value }
    # it { is_expected.to respond_to :parameter_value }
  end

  describe '#initialize' do
    context 'when variable is missing' do
      before do
        map.delete(:variable)
      end

      it 'raises an error' do
        expect { described_class.new(map) }.to raise_error(Qa::InvalidConfiguration, 'variable is required')
      end
    end

    context 'when invalid required value' do
      before do
        map[:required] = 'BAD_REQUIRED'
      end

      it 'raises an error' do
        expect { described_class.new(map) }.to raise_error(Qa::InvalidConfiguration, 'required must be true or false')
      end
    end
  end

  describe '#variable' do
    it 'returns the configured variable' do
      expect(subject.variable).to eq 'subauth'
    end
  end

  describe '#simple_value' do
    context 'when sub_value is not passed in' do
      context 'and default is not defined' do
        context 'and variable is required' do
          before do
            map[:required] = true
          end

          it 'raises error' do
            expect { subject.simple_value }.to raise_error(StandardError, 'subauth is required, but missing')
          end
        end

        context 'and variable is not required' do
          before do
            map[:required] = false
          end

          it 'returns empty string' do
            expect(subject.simple_value).to eq ''
          end
        end
      end

      context 'and default is defined' do
        before do
          map[:required] = false
          map[:default] = 'personal_name'
        end

        it 'returns the default' do
          expect(subject.simple_value).to eq 'personal_name'
        end
      end
    end

    context 'when sub_value is passed in' do
      before do
        map[:required] = true
      end

      it 'returns passed in sub_value' do
        expect(subject.simple_value('corporate_name')).to eq 'corporate_name'
      end
    end

    context 'when sub_value should be encoded' do
      before do
        map[:encode] = true
      end

      it 'returns encoded sub_value' do
        expect(subject.simple_value('http://example.org/over/the_rainbow')).to eq 'http%3A%2F%2Fexample%2Eorg%2Fover%2Fthe_rainbow'
      end
    end
  end
end
