require 'spec_helper'

RSpec.describe Qa::LinkedData::AuthorityUrlService do
  let(:authority) { :OCLC_FAST }
  let(:search_config) { Qa::Authorities::LinkedData::Config.new(authority).search }
  let(:term_config) { Qa::Authorities::LinkedData::Config.new(authority).term }
  let(:action_config) { search_config }

  let(:subauthority) { nil }
  let(:action) { :search }
  let(:action_request) { "mark+twain" }
  let(:substitutions) do
    {}
  end

  describe '.build_url' do
    let(:request_header) do
      {
        subauthority: subauthority,
        replacements: substitutions
      }
    end
    context 'when authority is not registered' do
      let(:authority) { :BAD_AUTHORITY }

      it 'raises error' do
        expected_error = Qa::InvalidLinkedDataAuthority
        expected_error_message = "Unable to initialize linked data authority 'BAD_AUTHORITY'"
        expect { described_class.build_url(action_config: action_config, action: action, action_request: action_request, request_header: request_header) }
          .to raise_error(expected_error, expected_error_message)
      end
    end

    # TODO: elr - currently uses the default subauthority if the one passed in isn't supported
    context 'when subauthority is not supported' do
      let(:subauthority) { :BAD_SUBAUTHORITY }

      it 'raises error' do
        skip "Pending better handling of unsupported subauthorities"
        expected_error = Qa::InvalidLinkedDataAuthority
        expected_error_message = "Unable to initialize linked data sub-authority BAD_SUBAUTHORITY"
        expect { described_class.build_url(action_config: action_config, action: action, action_request: action_request, request_header: request_header) }
          .to raise_error(expected_error, expected_error_message)
      end
    end

    context 'when invalid action is specified' do
      let(:action) { :BAD_ACTION }

      it 'raises error' do
        expected_error = Qa::UnsupportedAction
        expected_error_message = "BAD_ACTION Not Supported - Action must be one of the supported actions (e.g. :term, :search)"
        expect { described_class.build_url(action_config: action_config, action: action, action_request: action_request, request_header: request_header) }
          .to raise_error(expected_error, expected_error_message)
      end
    end

    context 'when action_request is missing' do
      let(:action_request) { nil }

      it 'raises error' do
        expected_error = Qa::IriTemplate::MissingParameter
        expected_error_message = "query is required, but missing"
        expect { described_class.build_url(action_config: action_config, action: action, action_request: action_request, request_header: request_header) }
          .to raise_error(expected_error, expected_error_message)
      end
    end

    context 'when no errors' do
      subject do
        described_class.build_url(action_config: action_config, action: action, action_request: action_request, request_header: request_header)
      end

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
        let(:action_config) { term_config }
        let(:action_request) { 'n79021164' }

        it 'returns template with substitutions' do
          expected_url = 'http://id.worldcat.org/fast/n79021164'
          expect(subject).to eq expected_url
        end
      end
    end
  end
end
