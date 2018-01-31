require 'spec_helper'

RSpec.describe Qa::LinkedData::AuthorityUrlService do
  before do
    Qa::LinkedData::AuthorityRegistryService.empty
    Qa::LinkedData::AuthorityRegistryService.add(Qa::LinkedData::Config::AuthorityConfig.new(:OCLC_FAST))
  end

  let(:authority) { :OCLC_FAST }
  let(:subauthority) { nil }
  let(:action) { :search }
  let(:action_request) { "mark+twain" }
  let(:substitutions) do
    {}
  end

  describe '.build_url' do
    context 'when authority is not registered' do
      let(:authority) { :BAD_AUTHORITY }

      it 'raises error' do
        expected_error = Qa::InvalidLinkedDataAuthority
        expected_error_message = "Authority (BAD_AUTHORITY) is not registered.  Place configuration in config/authorities/linked_data and restart server."
        expect { described_class.build_url(
            authority: authority, subauthority: subauthority, action: action, action_request: action_request, substitutions: substitutions) }.
            to raise_error(expected_error, expected_error_message)
      end
    end

    context 'when subauthority is not supported' do
      let(:subauthority) { :BAD_SUBAUTHORITY }

      it 'raises error' do
        expected_error = Qa::InvalidLinkedDataAuthority
        expected_error_message = "Unable to initialize linked data sub-authority BAD_SUBAUTHORITY"
        expect { described_class.build_url(
            authority: authority, subauthority: subauthority, action: action, action_request: action_request, substitutions: substitutions) }.
            to raise_error(expected_error, expected_error_message)
      end
    end

    context 'when invalid action is specified' do
      let(:action) { :BAD_ACTION }

      it 'raises error' do
        expected_error = Qa::InvalidConfiguration
        expected_error_message = "Authority does not support action BAD_ACTION"
        expect { described_class.build_url(
            authority: authority, subauthority: subauthority, action: action, action_request: action_request, substitutions: substitutions) }.
            to raise_error(expected_error, expected_error_message)
      end
    end

    context 'when action_request is missing' do
      let(:action_request) { nil }

      it 'raises error' do
        expected_error = Qa::IriTemplate::MissingParameter
        expected_error_message = "query is required, but missing"
        expect { described_class.build_url(
            authority: authority, subauthority: subauthority, action: action, action_request: action_request, substitutions: substitutions) }.
            to raise_error(expected_error, expected_error_message)
      end
    end


    subject do
      described_class.build_url(authority: authority, subauthority: subauthority, action: action, action_request: action_request, substitutions: substitutions)
    end

    context 'when no errors' do
      context 'and performing search action' do
        context 'and all substitutions specified' do
          let(:substitutions) do
            HashWithIndifferentAccess.new(
                maximumRecords: 10,
                language: 'fr'
            )
          end
          let(:subauthority) { 'personal_name' }
          let(:action_request) { 'mark twain' }

          it 'returns template with substitutions' do
            expected_url = 'http://experimental.worldcat.org/fast/search?query=oclc.personalName+all+%22mark twain%22&sortKeys=usage&maximumRecords=10'
            expect(subject).to eq expected_url
          end
        end

        context 'when no substitutions specified' do
          let(:action_request) { 'mark twain' }

          it 'returns template with substitutions' do
            expected_url = 'http://experimental.worldcat.org/fast/search?query=cql.any+all+%22mark twain%22&sortKeys=usage&maximumRecords=20'
            expect(subject).to eq expected_url
          end
        end
      end

      context 'and performing term action' do
        let(:action) { :term }
        let(:action_request) { 'n79021164' }

        it 'returns template with substitutions' do
          expected_url = 'http://id.worldcat.org/fast/n79021164'
          expect(subject).to eq expected_url
        end
      end
    end
  end
end
