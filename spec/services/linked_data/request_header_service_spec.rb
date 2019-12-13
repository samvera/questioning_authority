require 'spec_helper'

RSpec.describe Qa::LinkedData::RequestHeaderService do
  let(:request) { double }
  let(:request_id) { 'anID' }
  let(:some_params) { double }
  let(:location) { double }
  let(:fake_ip) { '111.22.33.4444' }
  let(:city) { 'Ithaca' }
  let(:state) { 'New York' }
  let(:country) { 'US' }
  before do
    allow(request).to receive(:request_id).and_return(request_id)
    allow(request).to receive_message_chain(:path_parameters, :[]).with(:action).and_return('search') # rubocop:disable RSpec/MessageChain
    allow(request).to receive(:location).and_return(location)
    allow(request).to receive(:ip).and_return(fake_ip)
    allow(location).to receive(:city).and_return(city)
    allow(location).to receive(:state).and_return(state)
    allow(location).to receive(:country).and_return(country)
  end

  describe '#initialize' do
    context 'when Qa.config.suppress_ip_data_from_log is true' do
      before { allow(Qa).to receive_message_chain(:config, :suppress_ip_data_from_log).and_return(true) } # rubocop:disable RSpec/MessageChain
      it 'does not include IP info in log message' do
        expect(Rails.logger).to receive(:info).with("******** SEARCH")
        described_class.new(request: request, params: some_params)
      end
    end

    context 'when Qa.config.suppress_ip_data_from_log is false' do
      before { allow(Qa).to receive_message_chain(:config, :suppress_ip_data_from_log).and_return(false) } # rubocop:disable RSpec/MessageChain
      it 'does include IP info in log message' do
        expect(Rails.logger).to receive(:info).with("******** SEARCH from IP #{fake_ip} in {city: #{city}, state: #{state}, country: #{country}}")
        described_class.new(request: request, params: some_params)
      end
    end
  end

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
