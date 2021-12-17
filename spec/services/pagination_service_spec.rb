require 'spec_helper'

RSpec.describe Qa::PaginationService do
  let(:results) do
    results = []
    1.upto(36) { |i| results << { "id": i.to_s, "label": "term #{i}" } }
    results
  end
  let(:request) { instance_double(ActionDispatch::Request) }
  let(:requested_format) { :json }
  let(:params) do
    {
      "q" => "n",
      "controller" => "qa/terms",
      "action" => "search",
      "vocab" => "local",
      "subauthority" => "my_terms"
    }.with_indifferent_access
  end
  let(:query_params) do
    { "q" => "term" }.with_indifferent_access
  end

  let(:service) do
    described_class.new(request: request,
                        results: results,
                        format: requested_format)
  end
  let(:base_url) { 'http://example.com' }
  let(:url_path) { '/qa/search/local/my_terms' }
  let(:query_string) { 'q=term' }

  before do
    allow(request).to receive(:params).and_return(params)
    allow(request).to receive(:query_parameters).and_return(query_params)
    allow(request).to receive(:query_string).and_return(query_string)
    allow(request).to receive(:base_url).and_return(base_url)
    allow(request).to receive(:path).and_return(url_path)
  end

  describe '#build_response' do
    let(:response) { service.build_response }

    # rubocop:disable RSpec/NestedGroups
    context 'when json format (default) is requested' do
      context 'and page_offset is missing' do
        context 'and page_limit is missing' do
          it 'returns all results as an array' do
            expect(response).to match_array(results)
          end
        end

        context 'and page_limit is passed in as "3"' do
          before { params[:page_limit] = "3" }

          it 'returns the first 3 results as an array' do
            expect(response).to match_array(results[0..2])
          end
        end
      end

      context 'and page_offset is passed in' do
        before { params[:page_offset] = "4" }

        context 'and page_limit is missing' do
          it 'returns the first DEFAULT_PAGE_LIMIT (10) records starting at 4th result' do
            expect(response).to match_array(results[3..12])
          end
        end

        context 'and page_limit is passed in' do
          before { params[:page_limit] = "3" }

          it 'returns the first 3 results as an array starting at 4th result' do
            expect(response).to match_array(results[3..5])
          end
        end
      end
    end

    context 'when json api format is requested' do
      let(:requested_format) { :jsonapi }
      let(:first_page) { "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=1" }
      let(:second_page) { "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=11" }
      let(:third_page) { "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=21" }
      let(:fourth_page) { "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=31" }
      let(:last_page) { fourth_page }
      let(:query_string) { 'q=term&format=jsonapi' }
      before do
        params[:format] = "jsonapi"
        query_params[:format] = "jsonapi"
      end

      context 'with invalid page_offset' do
        context 'that is not an integer' do
          let(:query_string) { 'q=term&format=jsonapi&page_offset=BAD' }

          before do
            params[:page_offset] = "BAD"
            query_params[:page_offset] = "BAD"
          end

          it 'sets invalid error' do
            error = response['errors'].first
            expect(error['status']).to eq '200'
            expect(error['source']).to include("page_offset" => "BAD")
            expect(error['title']).to eq 'Page Offset Invalid'
            expect(error['detail']).to eq "Page offset BAD is not an Integer.  Returning empty results."
          end

          it 'returns json api response with no results' do
            expect(response["data"]).to match_array([])
          end

          it "sets meta['page'] stats with page_offset showing the passed in value" do
            expect(response["meta"]["page"]["page_offset"]).to eq "BAD"
            expect(response["meta"]["page"]["page_limit"]).to eq "10"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "0"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets prev and next links to nil" do
            expect(response['links']['prev']).to be_nil
            expect(response['links']['next']).to be_nil
          end

          it "uses request values in self link" do
            self_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_offset=BAD"
            expect(response['links']['self']).to eq self_url
          end

          it "uses valid values in first and last links" do
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq last_page
          end
        end

        context 'that is < 1' do
          let(:query_string) { 'q=term&format=jsonapi&page_offset=0' }
          before do
            params[:page_offset] = "0"
            query_params[:page_offset] = "0"
          end

          it 'sets out of range error' do
            error = response['errors'].first
            expect(error['status']).to eq '200'
            expect(error['source']).to include("page_offset" => "0")
            expect(error['title']).to eq 'Page Offset Out of Range'
            expect(error['detail']).to eq "Page offset 0 < 1 (first result).  Returning empty results."
          end

          it 'returns json api response with no results' do
            expect(response["data"]).to match_array([])
          end

          it "sets meta['page'] stats with page_offset showing the passed in value" do
            expect(response["meta"]["page"]["page_offset"]).to eq "0"
            expect(response["meta"]["page"]["page_limit"]).to eq "10"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "0"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets prev and next links to nil" do
            expect(response['links']['prev']).to be_nil
            expect(response['links']['next']).to be_nil
          end

          it "uses request values in self link" do
            self_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_offset=0"
            expect(response['links']['self']).to eq self_url
          end

          it "uses valid values in first and last links" do
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq last_page
          end
        end

        context 'that is > number of results found' do
          let(:query_string) { 'q=term&format=jsonapi&page_offset=40' }
          before do
            params[:page_offset] = "40"
            query_params[:page_offset] = "40"
          end

          it 'sets out of range error' do
            error = response['errors'].first
            expect(error['status']).to eq '200'
            expect(error['source']).to include("page_offset" => "40")
            expect(error['title']).to eq 'Page Offset Out of Range'
            expect(error['detail']).to eq "Page offset 40 > 36 (total number of results).  Returning empty results."
          end

          it 'returns json api response with no results' do
            expect(response["data"]).to match_array([])
          end

          it "sets meta['page'] stats with page_offset showing the passed in value" do
            expect(response["meta"]["page"]["page_offset"]).to eq "40"
            expect(response["meta"]["page"]["page_limit"]).to eq "10"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "0"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets prev and next links to nil" do
            expect(response['links']['prev']).to be_nil
            expect(response['links']['next']).to be_nil
          end

          it "uses request values in self link" do
            self_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_offset=40"
            expect(response['links']['self']).to eq self_url
          end

          it "uses valid values in first and last links" do
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq last_page
          end
        end
      end

      context 'with invalid page_limit' do
        context 'that is not an integer' do
          let(:query_string) { 'q=term&format=jsonapi&page_limit=BAD' }
          before do
            params[:page_limit] = "BAD"
            query_params[:page_limit] = "BAD"
          end

          it 'sets invalid error' do
            error = response['errors'].first
            expect(error['status']).to eq '200'
            expect(error['source']).to include("page_limit" => "BAD")
            expect(error['title']).to eq 'Page Limit Invalid'
            expect(error['detail']).to eq "Page limit BAD is not an Integer.  Returning empty results."
          end

          it 'returns json api response with no results' do
            expect(response["data"]).to match_array([])
          end

          it "sets meta['page'] stats with page_limit showing the passed in value" do
            expect(response["meta"]["page"]["page_offset"]).to eq "1"
            expect(response["meta"]["page"]["page_limit"]).to eq "BAD"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "0"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets prev and next links to nil" do
            expect(response['links']['prev']).to be_nil
            expect(response['links']['next']).to be_nil
          end

          it "uses request values in self link" do
            self_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=BAD"
            expect(response['links']['self']).to eq self_url
          end

          it "uses valid values in first and last links" do
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq last_page
          end
        end

        context 'that is < 1' do
          let(:query_string) { 'q=term&format=jsonapi&page_limit=0' }
          before do
            params[:page_limit] = "0"
            query_params[:page_limit] = "0"
          end

          it 'sets out of range error' do
            error = response['errors'].first
            expect(error['status']).to eq '200'
            expect(error['source']).to include("page_limit" => "0")
            expect(error['title']).to eq 'Page Limit Out of Range'
            expect(error['detail']).to eq "Page limit 0 < 1 (minimum limit).  Returning empty results."
          end

          it 'returns json api response with no results' do
            expect(response["data"]).to match_array([])
          end

          it "sets meta['page'] stats with page_limit showing the passed in value" do
            expect(response["meta"]["page"]["page_offset"]).to eq "1"
            expect(response["meta"]["page"]["page_limit"]).to eq "0"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "0"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets prev and next links to nil" do
            expect(response['links']['prev']).to be_nil
            expect(response['links']['next']).to be_nil
          end

          it "uses request values in self link" do
            self_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=0"
            expect(response['links']['self']).to eq self_url
          end

          it "uses valid values in first and last links" do
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq last_page
          end
        end
      end

      context 'with multiple errors' do
        context 'where page_offset is > number of results found and page_limit is < 1' do
          let(:query_string) { 'q=term&format=jsonapi&page_limit=0&page_offset=40' }
          before do
            params[:page_limit] = "0"
            params[:page_offset] = "40"
            query_params[:page_limit] = "0"
            query_params[:page_offset] = "40"
          end

          it 'sets page_offset out of range and page_limit out of range errors' do
            expect(response['errors'].size).to eq 2
            offset_error_is_first = response['errors'].first['title'].starts_with? 'Page Offset'
            if offset_error_is_first
              offset_error = response['errors'].first
              limit_error = response['errors'].second
            else
              limit_error = response['errors'].first
              offset_error = response['errors'].second
            end

            expect(offset_error['status']).to eq '200'
            expect(offset_error['source']).to include("page_offset" => "40")
            expect(offset_error['title']).to eq 'Page Offset Out of Range'
            expect(offset_error['detail']).to eq "Page offset 40 > 36 (total number of results).  Returning empty results."

            expect(limit_error['status']).to eq '200'
            expect(limit_error['source']).to include("page_limit" => "0")
            expect(limit_error['title']).to eq 'Page Limit Out of Range'
            expect(limit_error['detail']).to eq "Page limit 0 < 1 (minimum limit).  Returning empty results."
          end

          it 'returns json api response with no results' do
            expect(response["data"]).to match_array([])
          end

          it "sets meta['page'] stats with page_offset and page_limit showing the passed in values" do
            expect(response["meta"]["page"]["page_offset"]).to eq "40"
            expect(response["meta"]["page"]["page_limit"]).to eq "0"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "0"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets prev and next links to nil" do
            expect(response['links']['prev']).to be_nil
            expect(response['links']['next']).to be_nil
          end

          it "uses request values in self link" do
            self_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=0&page_offset=40"
            expect(response['links']['self']).to eq self_url
          end

          it "uses valid values in first and last links" do
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq last_page
          end
        end
      end

      context 'with page_offset missing' do
        context 'and page_limit is missing' do
          it 'returns the first DEFAULT_PAGE_LIMIT (10) records' do
            expect(response["data"]).to match_array(results[0..9])
          end

          it "sets meta['page'] stats" do
            expect(response["meta"]["page"]["page_offset"]).to eq "1"
            expect(response["meta"]["page"]["page_limit"]).to eq described_class::DEFAULT_PAGE_LIMIT.to_s
            expect(response["meta"]["page"]["actual_page_size"]).to eq described_class::DEFAULT_PAGE_LIMIT.to_s
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets prev link to nil and next link to next page" do
            next_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=11"
            expect(response['links']['prev']).to be_nil
            expect(response['links']['next']).to eq next_url
          end

          it "sets first and self links to first page and last link to third page" do
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq last_page
            expect(response['links']['self']).to eq first_page
          end
        end

        context 'and page_limit is passed in' do
          let(:query_string) { 'q=term&format=jsonapi&page_limit=8' }
          let(:first_page) { "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=8&page_offset=1" }
          let(:second_page) { "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=8&page_offset=9" }
          let(:fifth_page) { "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=8&page_offset=33" }
          before do
            params[:page_limit] = "8"
            query_params[:page_limit] = "8"
          end

          it 'returns json api response with the first 3 results as an array' do
            expect(response["data"]).to match_array(results[0..7])
          end

          it "sets meta['page'] stats" do
            expect(response["meta"]["page"]["page_offset"]).to eq "1"
            expect(response["meta"]["page"]["page_limit"]).to eq "8"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "8"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets prev link to nil and next link to next page" do
            expect(response['links']['prev']).to be_nil
            expect(response['links']['next']).to eq second_page
          end

          it "sets first and self links to first page and last link to sixth page" do
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq fifth_page
            expect(response['links']['self']).to eq first_page
          end
        end
      end

      context 'with page_offset passed being the middle of a page' do
        let(:query_string) { 'q=term&format=jsonapi&page_offset=4' }
        before do
          params[:page_offset] = "4"
          query_params[:page_offset] = "4"
        end

        context 'and page_limit is missing' do
          it 'returns json api response with the first DEFAULT_PAGE_LIMIT (10) records starting at 4th result' do
            expect(response["data"]).to match_array(results[3..12])
          end

          it "sets meta['page'] stats" do
            expect(response["meta"]["page"]["page_offset"]).to eq "4"
            expect(response["meta"]["page"]["page_limit"]).to eq described_class::DEFAULT_PAGE_LIMIT.to_s
            expect(response["meta"]["page"]["actual_page_size"]).to eq described_class::DEFAULT_PAGE_LIMIT.to_s
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets self to requested page_offset and default page_limit" do
            self_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=4"
            expect(response['links']['self']).to eq self_url
          end

          it "sets prev link to first page and next link to next offset" do
            first_page = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=1"
            next_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=14"
            expect(response['links']['prev']).to eq first_page
            expect(response['links']['next']).to eq next_url
          end

          it "sets first to first page and last link to third page" do
            first_page = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=1"
            third_page = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=31"
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq third_page
          end
        end
      end

      context 'and there are no results' do
        let(:results) { [] }

        it 'returns no results' do
          expect(response["data"]).to match_array([])
        end

        it "sets meta['page'] stats" do
          expect(response["meta"]["page"]["page_offset"]).to eq "1"
          expect(response["meta"]["page"]["page_limit"]).to eq "10"
          expect(response["meta"]["page"]["actual_page_size"]).to eq "0"
          expect(response["meta"]["page"]["total_num_found"]).to eq "0"
        end

        it 'sets links with prev and next set to nil, last set to first' do
          expect(response['links']["self"]).to eq first_page
          expect(response['links']["first"]).to eq first_page
          expect(response['links']["prev"]).to eq nil
          expect(response['links']["next"]).to eq nil
          expect(response['links']["last"]).to eq first_page
        end

        it 'does not include errors' do
          expect(response.key?('errors')).to eq false
        end
      end

      context 'and results do not include a full page' do
        context 'and there are several results in range' do
          let(:query_string) { 'q=term&format=jsonapi&page_offset=31&page_limit=10' }

          before do
            params[:page_offset] = "31"
            query_params[:page_offset] = "31"
          end

          it 'returns json api response with a partial page of results starting at 11th result' do
            expect(response["data"]).to match_array(results[30..35])
          end

          it "sets meta['page'] stats" do
            expect(response["meta"]["page"]["page_offset"]).to eq "31"
            expect(response["meta"]["page"]["page_limit"]).to eq "10"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "6"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets self to last page" do
            expect(response['links']['self']).to eq last_page
          end

          it "sets prev link to 3rd page and next link to nil" do
            expect(response['links']['prev']).to eq third_page
            expect(response['links']['next']).to eq nil
          end

          it "sets first to first page and last link to fourth page" do
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq last_page
          end
        end

        context 'and only the last result is in range' do
          let(:query_string) { "q=term&format=jsonapi&page_offset=#{results.length}" }
          before do
            params[:page_offset] = results.length.to_s
            query_params[:page_offset] = results.length.to_s
          end

          it 'returns json api response with a partial page with one result' do
            expect(response["data"]).to match_array(results[35..35])
          end

          it "sets meta['page'] stats" do
            expect(response["meta"]["page"]["page_offset"]).to eq "36"
            expect(response["meta"]["page"]["page_limit"]).to eq "10"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "1"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it "sets self to second page" do
            self_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=36"
            expect(response['links']['self']).to eq self_url
          end

          it "sets prev link to one page back and next link to nil" do
            # when offset is middle of a page, then prev will also be middle of
            # a page with `prev_offset = current_offset - page_limit`
            prev_url = "#{base_url}#{url_path}?q=term&format=jsonapi&page_limit=10&page_offset=26"
            expect(response['links']['prev']).to eq prev_url
            expect(response['links']['next']).to eq nil
          end

          it "sets first to first page and last link to second page" do
            # calculated assuming starting from offset=1
            expect(response['links']['first']).to eq first_page
            expect(response['links']['last']).to eq last_page
          end
        end
      end

      context 'and there are multiple pages of results' do
        # data defined in main section has 3 pages of data
        let(:query_string) { "q=term&format=jsonapi&page_offset=#{page_offset}" }
        before do
          params[:page_offset] = page_offset
          query_params[:page_offset] = page_offset
        end

        context 'and page_offset is start of first page' do
          let(:page_offset) { "1" }

          it 'returns json api response first page of results' do
            expect(response["data"]).to match_array(results[0..9])
          end

          it "sets meta['page'] stats" do
            expect(response["meta"]["page"]["page_offset"]).to eq "1"
            expect(response["meta"]["page"]["page_limit"]).to eq "10"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "10"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it 'sets links with prev set to nil' do
            expect(response['links']["self"]).to eq first_page
            expect(response['links']["first"]).to eq first_page
            expect(response['links']["prev"]).to be_nil
            expect(response['links']["next"]).to eq second_page
            expect(response['links']["last"]).to eq last_page
          end

          it 'does not include errors' do
            expect(response.key?('errors')).to eq false
          end
        end

        context 'and page_offset is start of second page' do
          let(:page_offset) { "11" }

          it 'returns json api response second page of results' do
            expect(response["data"]).to match_array(results[10..19])
          end

          it "sets meta['page'] stats" do
            expect(response["meta"]["page"]["page_offset"]).to eq "11"
            expect(response["meta"]["page"]["page_limit"]).to eq "10"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "10"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it 'sets links with prev and next having values' do
            expect(response['links']["self"]).to eq second_page
            expect(response['links']["first"]).to eq first_page
            expect(response['links']["prev"]).to eq first_page
            expect(response['links']["next"]).to eq third_page
            expect(response['links']["last"]).to eq last_page
          end

          it 'does not include errors' do
            expect(response.key?('errors')).to eq false
          end
        end

        context 'and page_offset is start of third page' do
          let(:page_offset) { "21" }

          it 'returns json api response third page of results' do
            expect(response["data"]).to match_array(results[20..29])
          end

          it "sets meta['page'] stats" do
            expect(response["meta"]["page"]["page_offset"]).to eq "21"
            expect(response["meta"]["page"]["page_limit"]).to eq "10"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "10"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it 'sets links with next set to nil' do
            expect(response['links']["self"]).to eq third_page
            expect(response['links']["first"]).to eq first_page
            expect(response['links']["prev"]).to eq second_page
            expect(response['links']["next"]).to eq last_page
            expect(response['links']["last"]).to eq last_page
          end

          it 'does not include errors' do
            expect(response.key?('errors')).to eq false
          end
        end

        context 'and page_offset is start of fourth page (last page)' do
          let(:page_offset) { "31" }

          it 'returns json api response third page of results' do
            expect(response["data"]).to match_array(results[30..39])
          end

          it "sets meta['page'] stats" do
            expect(response["meta"]["page"]["page_offset"]).to eq "31"
            expect(response["meta"]["page"]["page_limit"]).to eq "10"
            expect(response["meta"]["page"]["actual_page_size"]).to eq "6"
            expect(response["meta"]["page"]["total_num_found"]).to eq "36"
          end

          it 'sets links with next set to nil' do
            expect(response['links']["self"]).to eq last_page
            expect(response['links']["first"]).to eq first_page
            expect(response['links']["prev"]).to eq third_page
            expect(response['links']["next"]).to be_nil
            expect(response['links']["last"]).to eq last_page
          end

          it 'does not include errors' do
            expect(response.key?('errors')).to eq false
          end
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end
end
