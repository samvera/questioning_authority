# Service to construct a request header that includes optional attributes for search and fetch requests.
module Qa
  module LinkedData
    class PerformanceDataService
      # Construct performance data structure to include in the returned results (linked data module).
      # @param access_time_s [Float] time to fetch the data from the external source and populate it in an RDF graph
      # @param normalization_time_s [Float] time for QA to normalize the data
      # @param fetched_size [Float] size of data in the RDF graph (in bytes)
      # @param normalized_size [Float] size of the normalized data string (in bytes)
      # @returns [Hash] performance data
      # @see Qa::Authorities::LinkedData::SearchQuery
      # @see Qa::Authorities::LinkedData::FindTerm
      def self.performance_data(access_time_s:, normalize_time_s:, fetched_size:, normalized_size:)
        {
          fetch_time_s: access_time_s,
          normalization_time_s: normalize_time_s,
          fetched_bytes: fetched_size,
          normalized_bytes: normalized_size,
          fetch_bytes_per_s: fetched_size / access_time_s,
          normalization_bytes_per_s: normalized_size / normalize_time_s,
          total_time_s: (access_time_s + normalize_time_s)
        }
      end
    end
  end
end
