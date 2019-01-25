require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::ContextMap do
  subject { described_class.new(context_map) }

  before do
    # simulate the existence of the i18n entries
    allow(I18n).to receive(:t).and_call_original
    allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.dates', 'default_Dates').and_return('Dates')
    allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.authoritative_label', 'default_Authoritative Label').and_return('Authoritative Label')
    allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.birth_date', 'default_Birth').and_return('Birth')
    allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.death_date', 'default_Death').and_return('Death')
  end

  let(:context_map) do
    {
      groups: {
        dates: {
          group_label_i18n: 'qa.linked_data.authority.locnames_ld4l_cache.dates',
          group_label_default: 'default_Dates'
        }
      },
      properties: [
        {
          property_label_i18n: 'qa.linked_data.authority.locgenres_ld4l_cache.authoritative_label',
          property_label_default: 'default_Authoritative Label',
          ldpath: 'madsrdf:authoritativeLabel',
          selectable: true,
          drillable: false
        },
        {
          group_id: 'dates',
          property_label_i18n: 'qa.linked_data.authority.locnames_ld4l_cache.birth_date',
          property_label_default: 'default_Birth',
          ldpath: 'madsrdf:identifiesRWO/madsrdf:birthDate/schema:label',
          selectable: false,
          drillable: false
        },
        {
          group_id: 'dates',
          property_label_i18n: 'qa.linked_data.authority.locnames_ld4l_cache.death_date',
          property_label_default: 'default_Death',
          ldpath: 'madsrdf:identifiesRWO/madsrdf:deathDate/schema:label',
          selectable: false,
          drillable: false
        }
      ]
    }
  end

  describe '#properties' do
    it 'returns the configured url template' do
      expect(subject.properties.size).to eq 3
      expect(subject.properties.first).to be_kind_of Qa::LinkedData::Config::ContextPropertyMap
    end
  end

  describe '#group_label' do
    context 'when map defines group_label_i18n key' do
      context 'and i18n translation is defined in locales' do
        it 'returns the translated text' do
          expect(subject.group_label(:dates)).to eq 'Dates'
        end
      end

      context 'and i18n translation is NOT defined in locales' do
        context 'and default is defined in the map' do
          before do
            allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.dates', 'default_Dates').and_return('default_Dates')
          end

          it 'returns the default value' do
            expect(subject.group_label(:dates)).to eq 'default_Dates'
          end
        end

        context 'and default is NOT defined in the map' do
          let(:groups) do
            {
              dates: {
                group_label_i18n: 'qa.linked_data.authority.locnames_ld4l_cache.dates'
              }
            }
          end
          before do
            context_map[:groups] = groups
            allow(I18n).to receive(:t).with('qa.linked_data.authority.locnames_ld4l_cache.dates', nil).and_return(nil)
          end

          it 'returns nil' do
            expect(subject.group_label(:dates)).to eq nil
          end
        end
      end
    end

    context 'when map does NOT define group_label_i18n key' do
      context 'and default is defined in map' do
        let(:groups) do
          {
            dates: {
              group_label_default: 'default_Dates'
            }
          }
        end
        before do
          context_map[:groups] = groups
        end

        it 'returns the default value' do
          expect(subject.group_label(:dates)).to eq 'default_Dates'
        end
      end

      context 'and default is NOT defined in map' do
        let(:groups) do
          {
            dates: {}
          }
        end
        before do
          context_map[:groups] = groups
        end

        it 'returns nil' do
          expect(subject.group_label(:dates)).to eq nil
        end
      end
    end
  end
end
