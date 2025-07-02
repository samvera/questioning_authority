require 'rdf'
require 'rdf/ntriples'
require 'net/http'
require 'json'

module Qa::Authorities
  class Discogs::GenericAuthority < Base
    include WebServiceBase
    include Discogs::DiscogsTranslation
    include Discogs::DiscogsUtils

    class_attribute :discogs_secret, :discogs_key, :discogs_user_token
    attr_accessor :primary_artists, :selected_format, :work_uri, :instance_uri

    # @param [String] subauthority to use
    def initialize(subauthority)
      super()
      @subauthority = subauthority
      self.primary_artists = []
      self.work_uri = "workn1"
      self.instance_uri = "instn1"
    end

    # @param [String] the query
    # @param [Class] QA::TermsController
    # @return json results
    def search(q, tc)
      # Discogs distinguishes between masters and releases, where a release represents a specific
      # physical or digital object and a master represents a set of similar releases. Use of a
      # subauthority (e.g., /qa/search/discogs/master) will target a specific type. Using the "all"
      #  subauthority will search for both types.
      unless discogs_user_token.present? || (discogs_key && discogs_secret)
        Rails.logger.error "Questioning Authority tried to call Discogs, but no user token, secret and/or key were set."
        return []
      end
      response = json(build_query_url(q, tc))
      if tc.params["response_header"] == "true"
        response_hash = {}
        response_hash["results"] = parse_authority_response(response)
        response_hash["response_header"] = build_response_header(response)
        return response_hash
      end
      parse_authority_response(response)
    end

    # If the subauthority = "all" (though it shouldn't), call the fetch_discogs_results method to determine
    # whether the id matches a release or master. And if the requested format is json-ld, call the build_graph
    # method in the translation module; otherwise, just return the Discogs json.  check the response to
    # determine if it should go to the translation module.
    #
    # @param [String] the Discogs id of the selected item
    # @param [Class] QA::TermsController
    # @return results in requested format (supports: json, jsonld, n3, ntriples)
    def find(id, tc)
      response = tc.params["subauthority"].include?("all") ? fetch_discogs_results(id) : json(find_url(id, tc.params["subauthority"]))
      self.selected_format = tc.params["format"]
      return response if response["message"].present?
      return build_graph(response, format: :jsonld) if jsonld?(tc)
      return build_graph(response, format: :n3) if n3?(tc)
      return build_graph(response, format: :ntriples) if ntriples?(tc)
      response
    end

    # @param [String] the query
    # @param [String] the subauthority
    # @return [String] the url
    def build_query_url(q, tc)
      page = nil
      per_page = nil
      if tc.params["startRecord"].present?
        page = (tc.params["startRecord"].to_i - 1) / tc.params["maxRecords"].to_i + 1
        per_page = tc.params["maxRecords"]
      else
        page = tc.params["page"]
        per_page = tc.params["per_page"]
      end
      escaped_q = ERB::Util.url_encode(q)
      url = "https://api.discogs.com/database/search?q=#{escaped_q}&type=#{tc.params['subauthority']}&page=#{page}&per_page=#{per_page}"
      url += "&key=#{discogs_key}&secret=#{discogs_secret}" unless discogs_user_token.present?
      url
    end

    # @param [String] the id of the selected item
    # @param [String] the subauthority
    # @return [String] the url
    def find_url(id, subauthority)
      "https://api.discogs.com/#{subauthority}s/#{id}"
    end

    def json(url)
      if discogs_user_token.present?
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Discogs token=#{discogs_user_token}"
        request['User-Agent'] = 'HykuApp/1.0'

        response = http.request(request)
        JSON.parse(response.body)
      else
        super
      end
    end

    private

      # In the unusual case that we have an id and the subauthority is "all", we don't know which Discogs url to
      # use. If the id is a match for both a release and a master (or neither), return that info as the
      # message. Otherwise, return the data for the release or master.
      # @param [String] the id of the selected item
      # @return json results
      def fetch_discogs_results(id)
        release_resp = json(find_url(id, "release"))
        master_resp = json(find_url(id, "master"))
        message_status = check_for_msg_response(release_resp, master_resp)

        return { "message" => "Neither a master nor a release matches the requested ID." } if message_status == "no responses"
        if message_status == "two responses"
          return { "message" => "Both a master and a release match the requested ID.",
                   "resource_url" => ["https://api.discogs.com/masters/#{id}", "https://api.discogs.com/releases/#{id}"] }
        end
        return master_resp unless master_resp.key?("message")
        # return release_resp unless release_resp.key?("message")
        release_resp
      end

      # @param [Hash] the http response from discogs
      # @example returns parsed discogs data with context
      # [{
      # 	"uri": "https://www.discogs.com/Frank-Sinatra-And-The-Modernaires-Sorry-Why-Remind-Me/release/4212473",
      # 	"id": "4212473",
      # 	"label": "Frank Sinatra And The Modernaires - Sorry / Why Remind Me",
      # 	"context": [{
      # 		"property": "Image URL",
      # 		"values": ["https://img.discogs.com/1358693671-5430.jpeg.jpg"]
      # 	}, {
      # 		"property": "Year",
      # 		"values": ["1950"]
      # 	}, {
      # 		"property": "Record Labels",
      # 		"values": ["Columbia"]
      # 	}, {
      # 		"property": "Formats",
      # 		"values": ["Shellac", "10\"", "78 RPM"]
      # 	}, {
      # 		"property": "Type",
      # 		"values": ["release"]
      # 	}]
      # }]
      def parse_authority_response(response)
        response['results'].map do |result|
          { 'uri' => build_uri(result),
            'id' => result['id'].to_s,
            'label' => result['title'].to_s,
            'context' => assemble_search_context(result) }
        end
      end

      # @param [Hash] the http response from discogs
      # @param [Class] QA::TermsController
      # @example returns parsed discogs pagination data
      def build_response_header(response)
        start_record = (response['pagination']['page'] - 1) * response['pagination']['per_page'] + 1
        rh_hash = {}
        rh_hash['start_record'] = start_record
        rh_hash['requested_records'] = response['pagination']['per_page']
        rh_hash['retrieved_records'] = response['results'].length
        rh_hash['total_records'] = response['pagination']['items']
        rh_hash
      end

      # @param [Hash] the results hash from the JSON returned by Discogs
      def build_uri(result)
        result['uri'].present? ? "https://www.discogs.com" + result['uri'].to_s : result['resource_url'].to_s
      end

      # @param [Hash] the results hash from the JSON returned by Discogs
      def assemble_search_context(result)
        [{ "property" => "Image URL", "values" => get_context_for_string(result['cover_image']) },
         { "property" => "Year", "values" => get_context_for_string(result['year']) },
         { "property" => "Record Labels", "values" => get_context_for_array(result['label']) },
         { "property" => "Formats", "values" => get_context_for_array(result['format']) },
         { "property" => "Type", "values" => get_context_for_string(result['type']) }]
      end

      # checks if the param is null, returns appropriate value
      # @param [String] returns an empty string if item is not presentr
      def get_context_for_string(item)
        [item.present? ? item.to_s : ""]
      end

      # checks if the param is null, returns appropriate value
      # @param [Array] returns an empty array if item is not presentr
      def get_context_for_array(item)
        item.present? ? item : [""]
      end
  end
end
