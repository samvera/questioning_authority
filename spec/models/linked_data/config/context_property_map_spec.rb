require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::ContextPropertyMap do
  subject { described_class.new(property_map) }

  let(:property_map) do
    {
      group_id: 'dates',
      property_label_i18n: 'qa.linked_data.authority.locnames_ld4l_cache.birth_date',
      property_label_default: 'default_Birth',
      lpath: 'madsrdf:identifiesRWO/madsrdf:birthDate/schema:label',
      selectable: false,
      drillable: false
    }
  end

  describe 'model attributes' do
    it { is_expected.to respond_to :lpath }
  end

  describe '#initialize' do
    context 'when lpath is missing' do
      before { property_map.delete(:lpath) }

      it 'raises an error' do
        expect { subject }.to raise_error(Qa::InvalidConfiguration, 'lpath is required')
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
          allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.birth_date', 'default_Birth').and_return('Birth')
        end

        it 'returns the translated text' do
          expect(subject.label).to eq 'Birth'
        end
      end

      context 'and i18n translation is NOT defined in locales' do
        context 'and default is defined in the map' do
          before do
            allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.birth_date', 'default_Birth').and_return('default_Birth')
          end

          it 'returns the default value' do
            expect(subject.label).to eq 'default_Birth'
          end
        end

        context 'and default is NOT defined in the map' do
          before do
            property_map.delete(:property_label_default)
            allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.birth_date', nil).and_return(nil)
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
end
