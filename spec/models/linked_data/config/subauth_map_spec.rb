require 'spec_helper'

RSpec.describe Qa::LinkedData::Config::SubauthMap do
  subject { described_class.new(config: subauth_map_config) }

  let(:subauth_map_config) do
    {
      topic: 'oclc.topic',
      geographic: 'oclc.geographic',
      personal_name: 'oclc.personalName',
      corporate_name: 'oclc.corporateName'
    }
  end

  describe '#subauth?' do
    it 'returns true if subauth as string is in the map' do
      expect(subject.subauth?('topic')).to be true
    end

    it 'returns true if subauth as symbol is in the map' do
      expect(subject.subauth?(:topic)).to be true
    end
  end

  describe '#external_name' do
    it 'returns the cooresponding subauth name used by the external authority' do
      expect(subject.external_name('geographic')).to eq 'oclc.geographic'
    end

    it 'returns false if subauth name is not found' do
      expect(subject.external_name('BAD SUBAUTH')).to be false
    end
  end

  describe '#external_name!' do
    it 'returns the cooresponding subauth name used by the external authority' do
      expect(subject.external_name!('personal_name')).to eq 'oclc.personalName'
    end

    it 'raises error if subauth name is not found' do
      expect { subject.external_name!('BAD SUBAUTH') }.to raise_error(Qa::InvalidLinkedDataAuthority, "Unable to initialize linked data sub-authority BAD SUBAUTH")
    end
  end
end
