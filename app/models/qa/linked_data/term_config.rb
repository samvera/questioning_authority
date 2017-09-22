module Qa
  module LinkedData
    class TermConfig
      attribute_accessor :url # [Qa::LinkedData::UriTemplate::Uri] url template for accessing the authority
      attribute_accessor :subauth_map # [Qa::LinkedData::SubauthMap] map of subauth values to expected values at external authority
      attribute_accessor :results_map # [Qa::LinkedData::ResultsMap] map of result field to a predicate in the graph
    end
  end
end