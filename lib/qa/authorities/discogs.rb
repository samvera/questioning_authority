require 'rdf'
module Qa::Authorities
  class Discogs < Base
    extend ActiveSupport::Autoload
    autoload :DiscogsTranslation
    autoload :DiscogsUtils
    autoload :DiscogsWorksBuilder
    autoload :DiscogsInstanceBuilder
    include WebServiceBase
    include DiscogsTranslation

    class_attribute :discogs_secret, :discogs_key
    attr_accessor :primary_artists

    def initialize
      self.primary_artists = []
    end

    def search(q, tc)
      # Discogs distinguishes between masters and releases, where a release represents a specific
      # physical or digital object and a master represents a set of similar releases. Use of a
      # subauthority (e.g., /qa/search/discogs/master) will target a specific type. No subauthority
      # will search for both types.
      unless discogs_key && discogs_secret
        Rails.logger.error "Questioning Authority tried to call Discogs, but no secret and/or key were set."
        return []
      end
      subauthority = tc.params["subauthority"].present? ? tc.params["subauthority"] : ""
      parse_authority_response(json(build_query_url(q, subauthority)))
    end

    def find(id, tc)
      # If the requested format is json-ld, call the build_graph method in the translation module;
      # otherwise, just return the Discogs json. If there's no subauthority, check the response
      # to determine if it should go to the translation module.
      response = tc.params["subauthority"].present? ? json(find_url(id, tc.params["subauthority"])) : fetch_discogs_results(id)
      return build_graph(response) unless tc.params["format"] != "jsonld" || response["message"].present?
      response
    end

    def build_query_url(q, subauthority)
      escaped_q = URI.escape(q)
      "https://api.discogs.com/database/search?q=#{escaped_q}&type=#{subauthority}&key=#{discogs_key}&secret=#{discogs_secret}"
    end

    def find_url(id, subauthority)
      "https://api.discogs.com/#{subauthority}s/#{id}"
    end

    private

      # In the unusual case that we have an id but not a subauthority, we don't know which Discogs url to
      # use. If the id is a match for both a release and a master (or neither), return that info as the
      # message. Otherwise, return the data for the release or master.
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

      def check_for_msg_response(release_resp, master_resp)
        if release_resp.key?("message") && master_resp.key?("message")
          "no responses"
        elsif !release_resp.key?("message") && !master_resp.key?("message")
          "two responses"
        else
          "mixed"
        end
      end

      # @example parsed discogs data with context
      # {
      #   "uri": "/Frank-Sinatra-And-The-Modernaires-Sorry-Why-Remind-Me/release/4212473",
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
          { 'uri' => result['uri'].to_s,
            'id' => result['id'].to_s,
            'label' => result['title'].to_s,
            'context' => assemble_search_context(result) }
        end
      end

      def assemble_search_context(result)
        { "Image URL" => set_context_item(result['cover_image'], "string"),
          "Year" =>  set_context_item(result['year'], "string"),
          "Record Labels" => set_context_item(result['label'], "array"),
          "Formats" => set_context_item(result['format'], "array"),
          "Type" => set_context_item(result['type'], "string") }
      end

      def set_context_item(item, type)
        return [item.present? ? item.to_s : ""] if type == "string"
        return item.present? ? item : [""] if type == "array"
      end
  end
end
