module Qa
  module LinkedData
    class Term
      attribute_accessor :auth # [String] validates against authoritie filenames in /config/authorities/linked_data
      attribute_accessor :subauth # [String] (optional) validates against search config's subauth list
      attribute_accessor :term_id # [String] query passed in with request
      attribute_accessor :language # [String] parameter passed in with request
      attribute_accessor :replacements # [Hash] remaining parameters names and values
      attribute_accessor :url # [String] processed url with substitutions
      attribute_accessor :graph # [Graph] graph of results
      attribute_accessor :results # [String(json)] normalized and sorted results
    end
  end
end
