# frozen_string_literal: true
# spec/requests/cors_headers_spec.rb
require 'spec_helper'

describe "CORS OPTIONS requests" do # rubocop:disable RSpec/DescribeClass
  context 'when cors headers are enabled' do
    before do
      Qa.config.enable_cors_headers
    end

    it 'return CORS header info for index' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/terms/loc"
      correct_cors_response?
    end

    it 'return CORS header info for index with subauthority' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/terms/local/states"
      correct_cors_response?
    end

    it 'return CORS header info for search' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/search/loc"
      correct_cors_response?
    end

    it 'return CORS header info for search with subauthority' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/search/local/two_args?q=a query"
      correct_cors_response?
    end

    it 'return CORS header info for show' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/show/mesh/D000001"
      correct_cors_response?
    end

    it 'return CORS header info for show with subauthority' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/show/local/states/OH"
      correct_cors_response?
    end

    it 'return CORS header info for linked_data/search' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/search/linked_data/OCLC_FAST?q=my_query&maximumRecords=3"
      correct_cors_response?
    end

    it 'return CORS header info for linked_data/show' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/show/linked_data/OCLC_FAST/n24"
      correct_cors_response?
    end
  end

  def correct_cors_response?
    expect(response.code).to eq('204')
    expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
    expect(response.headers['Access-Control-Allow-Methods']).to eq 'GET, OPTIONS'
  end

  context 'when cors headers are disabled' do
    before do
      Qa.config.disable_cors_headers
    end

    it 'report method not supported for index' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/terms/loc"
      expect(response.code).to eq('501')
    end

    it 'report method not supported for index with subauthority' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/terms/local/states"
      expect(response.code).to eq('501')
    end

    it 'report method not supported for search' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/search/loc"
      expect(response.code).to eq('501')
    end

    it 'report method not supported for search with subauthority' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/search/local/two_args?q=a query"
      expect(response.code).to eq('501')
    end

    it 'report method not supported for show' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/show/mesh/D000001"
      expect(response.code).to eq('501')
    end

    it 'report method not supported for show with subauthority' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/show/local/states/OH"
      expect(response.code).to eq('501')
    end

    it 'report method not supported for linked_data/search' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/search/linked_data/OCLC_FAST?q=my_query&maximumRecords=3"
      expect(response.code).to eq('501')
    end

    it 'report method not supported for linked_data/show' do
      reset!
      integration_session.__send__ :process, 'OPTIONS', "/qa/show/linked_data/OCLC_FAST/n24"
      expect(response.code).to eq('501')
    end
  end
end
