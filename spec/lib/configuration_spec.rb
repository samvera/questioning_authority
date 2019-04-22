require 'spec_helper'

RSpec.describe Qa::Configuration do
  subject { described_class.new }

  describe '#enable_cors_headers' do
    it 'turns on cors headers support' do
      subject.enable_cors_headers
      expect(subject.cors_headers?).to be true
    end
  end

  describe '#disable_cors_headers' do
    it 'turns off cors headers support' do
      subject.disable_cors_headers
      expect(subject.cors_headers?).to be false
    end
  end

  describe '#valid_authority_reload_token?' do
    it 'defaults to invalid' do
      expect(subject.valid_authority_reload_token?('any value')).to be false
    end

    context 'when token is set to blank' do
      before do
        subject.authorized_reload_token = ''
      end

      it 'returns false if token matches' do
        expect(subject.valid_authority_reload_token?('')).to be false
      end

      it "returns false if token doesn't match" do
        expect(subject.valid_authority_reload_token?('any value')).to be false
      end
    end

    context 'when token has a value' do
      before do
        subject.authorized_reload_token = 'A_TOKEN'
      end

      it 'returns true if the passed in token matches' do
        expect(subject.valid_authority_reload_token?('A_TOKEN')).to be true
      end

      it 'returns false if the passed in token does not match' do
        expect(subject.valid_authority_reload_token?('BAD TOKEN')).to be false
      end
    end
  end

  describe '#default_language' do
    context 'when NOT configured' do
      it 'returns :en as the default language' do
        expect(subject.default_language).to be :en
      end
    end

    context 'when configured' do
      before do
        subject.default_language = [:fr]
      end

      it 'returns the configured default language' do
        expect(subject.default_language).to match_array [:fr]
      end
    end
  end

  describe '#limit_ldpath_to_context' do
    context 'when NOT configured' do
      it 'returns true' do
        expect(subject.limit_ldpath_to_context?).to be true
      end
    end

    context 'when configured' do
      before do
        subject.limit_ldpath_to_context = false
      end

      it 'returns the configured value' do
        expect(subject.limit_ldpath_to_context?).to be false
      end
    end
  end
end
