require 'spec_helper'

describe Qa::LinkedData::AuthorityService do
  let(:auth_names) do
    [:LOC,
     :LOD_ENCODING_CONFIG,
     :LOD_FULL_CONFIG,
     :LOD_FULL_CONFIG_1_0,
     :LOD_LANG_DEFAULTS,
     :LOD_LANG_MULTI_DEFAULTS,
     :LOD_LANG_NO_DEFAULTS,
     :LOD_LANG_PARAM,
     :LOD_MIN_CONFIG,
     :LOD_SEARCH_ONLY_CONFIG,
     :LOD_SORT,
     :LOD_TERM_ID_PARAM_CONFIG,
     :LOD_TERM_ONLY_CONFIG,
     :LOD_TERM_URI_PARAM_CONFIG,
     :OCLC_FAST]
  end

  describe '#authority_configs' do
    let(:result) { described_class.authority_configs }
    it 'returns all authorities' do
      expect(result).to be_kind_of(Hash)
      expect(result.keys).to match_array auth_names
      expect(result.values.first).to be_kind_of(Hash)
      expect(result.values.first).to have_key(:term)
      expect(result.values.first).to have_key(:search)
    end
  end

  describe '#authority_config' do
    let(:result) { described_class.authority_config(:LOD_FULL_CONFIG) }
    it 'returns a single authority' do
      expect(result).to be_kind_of(Hash)
      expect(result).to have_key(:term)
      expect(result).to have_key(:search)
    end
  end

  describe '#authority_names' do
    it "returns a list of all authorities' names" do
      expect(described_class.authority_names).to eq auth_names
    end
  end

  describe '#authority_details' do
    let(:term_details) do
      {
        "label" => "oclc_fast term (QA)",
        "uri" => "urn:qa:term:oclc_fast",
        "authority" => "oclc_fast",
        "action" => "term",
        "language" => ["en"]
      }
    end

    let(:search_details) do
      {
        "label" => "oclc_fast search (QA)",
        "uri" => "urn:qa:search:oclc_fast",
        "authority" => "oclc_fast",
        "action" => "search",
        "language" => ["en"]
      }
    end

    let(:search_details_with_subauth) do
      {
        "label" => "oclc_fast search topic (QA)",
        "uri" => "urn:qa:search:oclc_fast:topic",
        "authority" => "oclc_fast",
        "subauthority" => "topic",
        "action" => "search",
        "language" => ["en"]
      }
    end

    let(:details) { described_class.authority_details }

    it "returns a list with details for term without subauthorities" do
      expect(details).to include_hash(term_details)
    end

    it "returns a list with details for search without subauthorities" do
      expect(details).to include_hash(search_details)
    end

    it "returns a list with details for search with a subauthority" do
      expect(details).to include_hash(search_details_with_subauth)
    end
  end
end
