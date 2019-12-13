require 'spec_helper'

RSpec.describe Qa::LinkedData::RequestHeaderService do
  let(:request) { double }
  before { allow(SecureRandom).to receive(:uuid).and_return(request_id) }

  describe '#search_header' do
    let(:request_id) { 's1' }

    context 'when optional params are defined' do
      let(:search_params) do
        {
          'subauthority' => 'person',
          'lang' => 'sp',
          'maxRecords' => '4',
          'context' => 'true',
          'performance_data' => 'true',
          'response_header' => 'true'
        }.with_indifferent_access
      end
      before { allow(request).to receive(:env).and_return('HTTP_ACCEPT_LANGUAGE' => 'de') }

      it 'uses passed in params' do
        expected_results =
          {
            request: request,
            request_id: request_id,
            context: true,
            performance_data: true,
            replacements: { 'maxRecords' => '4' },
            response_header: true,
            subauthority: 'person',
            user_language: ['sp']
          }
        expect(described_class.new(request: request, params: search_params).search_header).to eq expected_results
      end
    end

    context 'when none of the optional params are defined' do
      context 'and request does not define language' do
        before { allow(request).to receive(:env).and_return('HTTP_ACCEPT_LANGUAGE' => nil) }
        it 'returns defaults' do
          expected_results =
            {
              request: request,
              request_id: request_id,
              context: false,
              performance_data: false,
              replacements: {},
              response_header: false,
              subauthority: nil,
              user_language: nil
            }
          expect(described_class.new(request: request, params: {}).search_header).to eq expected_results
        end
      end

      context 'and request does define language' do
        before { allow(request).to receive(:env).and_return('HTTP_ACCEPT_LANGUAGE' => 'de') }
        it 'returns defaults with language set to request language' do
          expected_results =
            {
              request: request,
              request_id: request_id,
              context: false,
              performance_data: false,
              replacements: {},
              response_header: false,
              subauthority: nil,
              user_language: ['de']
            }
          expect(described_class.new(request: request, params: {}).search_header).to eq expected_results
        end
      end
    end
  end

  describe '#fetch_header' do
    let(:request_id) { 'f1' }
    context 'when optional params are defined' do
      let(:fetch_params) do
        {
          'subauthority' => 'person',
          'lang' => 'sp',
          'extra' => 'data',
          'even' => 'more data',
          'format' => 'n3',
          'performance_data' => 'true',
          'response_header' => 'true'
        }.with_indifferent_access
      end
      before { allow(request).to receive(:env).and_return('HTTP_ACCEPT_LANGUAGE' => 'de') }

      it 'uses passed in params' do
        expected_results =
          {
            request: request,
            request_id: request_id,
            format: 'n3',
            performance_data: true,
            replacements: { 'extra' => 'data', 'even' => 'more data' },
            response_header: true,
            subauthority: 'person',
            user_language: ['sp']
          }
        expect(described_class.new(request: request, params: fetch_params).fetch_header).to eq expected_results
      end
    end

    context 'when none of the optional params are defined' do
      context 'and request does not define language' do
        before { allow(request).to receive(:env).and_return('HTTP_ACCEPT_LANGUAGE' => nil) }
        it 'returns defaults' do
          expected_results =
            {
              request: request,
              request_id: request_id,
              format: 'json',
              performance_data: false,
              replacements: {},
              response_header: false,
              subauthority: nil,
              user_language: nil
            }
          expect(described_class.new(request: request, params: {}).fetch_header).to eq expected_results
        end
      end

      context 'and request does define language' do
        before { allow(request).to receive(:env).and_return('HTTP_ACCEPT_LANGUAGE' => 'de') }
        it 'returns defaults with language set to request language' do
          expected_results =
            {
              request: request,
              request_id: request_id,
              format: 'json',
              performance_data: false,
              replacements: {},
              response_header: false,
              subauthority: nil,
              user_language: ['de']
            }
          expect(described_class.new(request: request, params: {}).fetch_header).to eq expected_results
        end
      end
    end
  end
end
