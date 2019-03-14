require 'rdf'
module Qa::Authorities
  class Discogs::GenericAuthority < Base
    include WebServiceBase
    include Discogs::DiscogsTranslation

    class_attribute :discogs_secret, :discogs_key
    attr_accessor :primary_artists

    # @param [String] subauthority to use
    def initialize(subauthority)
      @subauthority = subauthority
      self.primary_artists = []
    end

    # @param [String] the query
    # @param [Class] QA::TermsController
    # @return json results
    def search(q, tc)
      # Discogs distinguishes between masters and releases, where a release represents a specific
      # physical or digital object and a master represents a set of similar releases. Use of a
      # subauthority (e.g., /qa/search/discogs/master) will target a specific type. Using the "all"
      #  subauthority will search for both types.
      unless discogs_key && discogs_secret
        Rails.logger.error "Questioning Authority tried to call Discogs, but no secret and/or key were set."
        return []
      end
      parse_authority_response(json(build_query_url(q, tc.params["subauthority"])))
    end

    # If the subauthority = "all" (though it shouldn't), call the fetch_discogs_results method to determine
    # whether the id matches a release or master. And if the requested format is json-ld, call the build_graph
    # method in the translation module; otherwise, just return the Discogs json.  check the response to
    # determine if it should go to the translation module.
    #
    # @param [String] the Discogs id of the selected item
    # @param [Class] QA::TermsController
    # @return either json results or jsonld
    def find(id, tc)
      response = tc.params["subauthority"].include?("all") ? fetch_discogs_results(id) : json(find_url(id, tc.params["subauthority"]))
      return build_graph(response) unless tc.params["format"] != "jsonld" || response["message"].present?
      response
    end

    # @param [String] the query
    # @param [String] the subauthority
    # @return [String] the url
    def build_query_url(q, subauthority)
      escaped_q = ERB::Util.url_encode(q)
      "https://api.discogs.com/database/search?q=#{escaped_q}&type=#{subauthority}&key=#{discogs_key}&secret=#{discogs_secret}"
    end

    # @param [String] the id of the selected item
    # @param [String] the subauthority
    # @return [String] the url
    def find_url(id, subauthority)
      "https://api.discogs.com/#{subauthority}s/#{id}"
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

      # @param json results
      # @param json results
      # @return [String] status information
      def check_for_msg_response(release_resp, master_resp)
        if release_resp.key?("message") && master_resp.key?("message")
          "no responses"
        elsif !release_resp.key?("message") && !master_resp.key?("message")
          "two responses"
        else
          "mixed"
        end
      end

      # @param [Hash] the http response from discogs
      # @example returns parsed discogs data with context
      # {
      #   "uri": "https://api.discogs.com/releases/4212473",
      #   "id": "4212473",
      #   "label": "Frank Sinatra And The Modernaires - Sorry / Why Remind Me",
      # }
      #   "context": {
      #     "Image URL": [
      #       "https://img.discogs.com/2e-YoNr0dvmMgbzEN0hjHD6X0sU=/fit-in/600x580/filters:strip_icc():format(jpeg):mode_rgb():quality(90)/discogs-images/R-4212473-1358693671-5430.jpeg.jpg"
      #     ],
      #     "Year": [
      #       "1950"
      #     ],
      #     "Record Labels": [
      #       "Columbia"
      #     ],
      #     "Formats": [
      #       "Shellac",
      #       "10\"",
      #       "78 RPM"
      #     ],
      #     "Type": [
      #       "release"
      #     ]
      #   }
      def parse_authority_response(response)
        response['results'].map do |result|
          { 'uri' => result['resource_url'].to_s,
            'id' => result['id'].to_s,
            'label' => result['title'].to_s,
            'context' => assemble_search_context(result) }
        end
      end

      # @param [Hash] the results hash from the JSON returned by Discogs
      def assemble_search_context(result)
        { "Image URL" => get_context_for_string(result['cover_image']),
          "Year" =>  get_context_for_string(result['year']),
          "Record Labels" => get_context_for_array(result['label']),
          "Formats" => get_context_for_array(result['format']),
          "Type" => get_context_for_string(result['type']) }
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
