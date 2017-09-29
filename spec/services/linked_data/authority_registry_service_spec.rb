require 'spec_helper'

RSpec.describe Qa::LinkedData::AuthorityRegistryService do
  let(:auth_config_1) { instance_double("auth_config_1") }
  let(:auth_config_2) { instance_double("auth_config_2") }

  describe '.registered?' do
    before do
      described_class.empty
      allow(auth_config_1).to receive(:authority_name).and_return('auth_config_1')
      described_class.add(auth_config_1)
    end

    it 'returns true for registered configs' do
      expect(described_class).to be_registered('auth_config_1')
    end

    it 'returns false for unregistered configs' do
      expect(described_class).not_to be_registered('auth_config_2')
    end
  end

  describe '.add' do
    before do
      described_class.empty
      allow(auth_config_1).to receive(:authority_name).and_return('auth_config_1')
    end

    it 'has the added configs' do
      described_class.add(auth_config_1)
      expect(described_class).to be_registered('auth_config_1')
    end
  end

  describe '.remove' do
    before do
      described_class.empty
      allow(auth_config_1).to receive(:authority_name).and_return('auth_config_1')
      allow(auth_config_2).to receive(:authority_name).and_return('auth_config_2')
      described_class.add(auth_config_1)
      described_class.add(auth_config_2)
    end

    it 'removes designated config' do
      expect(described_class).to be_registered('auth_config_1')
      described_class.remove('auth_config_1')
      expect(described_class).not_to be_registered('auth_config_1')
    end

    it 'does not remove other configs' do
      expect(described_class).to be_registered('auth_config_2')
      described_class.remove('auth_config_1')
      expect(described_class).to be_registered('auth_config_2')
    end
  end

  describe '.retrieve' do
    before do
      described_class.empty
      allow(auth_config_1).to receive(:authority_name).and_return('auth_config_1')
      described_class.add(auth_config_1)
    end

    it 'has the added configs' do
      expect(described_class.retrieve('auth_config_1').authority_name).to eq('auth_config_1')
    end
  end

  describe '.update' do
    before do
      described_class.empty
      allow(auth_config_1).to receive(:authority_name).and_return('auth_config_1') # simulating the original config
      allow(auth_config_1).to receive(:foo).and_return('foo old value')
      allow(auth_config_2).to receive(:authority_name).and_return('auth_config_1') # simulating the same config with different values
      allow(auth_config_2).to receive(:foo).and_return('foo new value')
      described_class.add(auth_config_1)
    end

    it 'updates the configuration' do
      expect(described_class).to be_registered('auth_config_1')
      expect(described_class.retrieve('auth_config_1').foo).to eq('foo old value')
      described_class.update(auth_config_2)
      expect(described_class).to be_registered('auth_config_1')
      expect(described_class.retrieve('auth_config_1').foo).to eq('foo new value')
    end
  end
end
