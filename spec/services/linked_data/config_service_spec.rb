require 'spec_helper'

RSpec.describe Qa::LinkedData::ConfigService do
  let!(:config) { LINKED_DATA_AUTHORITIES_CONFIG[:LOD_FULL_CONFIG].fetch(:search) }

  describe '.extract_iri_template' do
    it 'returns an instance of iri_template' do
      expect(described_class.extract_iri_template(config: config)).to be_kind_of Qa::IriTemplate::Template
    end

    context 'when missing' do
      before { allow(config).to receive(:fetch).with(:url, nil).and_return(nil) }
      it 'raises an error' do
        expect { described_class.extract_iri_template(config: config) }.to raise_error(Qa::InvalidConfiguration, 'iri template is required')
      end
    end
  end

  describe '.extract_results_map' do
    it 'returns an instance of SearchResultsMap when search is requested' do
      expect(described_class.extract_results_map(config: config, results_type: Qa::LinkedData::ConfigService::SEARCH_RESULTS_MAP)).to be_kind_of Qa::LinkedData::Config::SearchResultsMap
    end

    it 'returns an instance of TermResultsMap when search is requested' do
      expect(described_class.extract_results_map(config: config, results_type: Qa::LinkedData::ConfigService::TERM_RESULTS_MAP)).to be_kind_of Qa::LinkedData::Config::TermResultsMap
    end

    context 'when missing' do
      before { allow(config).to receive(:fetch).with(:results, nil).and_return(nil) }
      it 'raises an error' do
        expect { described_class.extract_results_map(config: config, results_type: Qa::LinkedData::ConfigService::TERM_RESULTS_MAP) }.to raise_error(Qa::InvalidConfiguration, 'Results map is required')
      end
    end

    context 'when results_type is not supported' do
      it 'raises an error' do
        expect { described_class.extract_results_map(config: config, results_type: :BAD_TYPE) }.to raise_error(ArgumentError, 'Unsupported results_type BAD_TYPE')
      end
    end
  end

  describe '.extract_subauthorities_map' do
    it 'returns an instance of subauth_map' do
      expect(described_class.extract_subauthorities_map(config: config)).to be_kind_of Qa::LinkedData::Config::SubauthMap
    end

    context 'when missing' do
      before { allow(config).to receive(:fetch).with(:subauthorities, nil).and_return(nil) }
      it 'returns nil' do
        expect(described_class.extract_subauthorities_map(config: config)).to be_nil
      end
    end
  end

  describe '.extract_subauthority_variable' do
    before do
      custom_subauth = { subauth: 'custom_subauth' }
      allow(config).to receive(:fetch).with(:qa_replacement_patterns, nil).and_return(custom_subauth)
    end
    it 'returns the name of the template variable that is controlled by the subauth_map' do
      expect(described_class.extract_subauthority_variable(config: config)).to eq 'custom_subauth'
    end

    context 'when qa_replacement_patterns is missing' do
      before { allow(config).to receive(:fetch).with(:qa_replacement_patterns, nil).and_return(nil) }
      it 'returns default' do
        expect(described_class.extract_subauthority_variable(config: config)).to eq described_class::DEFAULT_SUBAUTH_VARIABLE
      end
    end

    context 'when subauth is missing' do
      before do
        typo_subauth = { subauht: 'custom_subauth_not_picked_up_due_to_typo' }
        allow(config).to receive(:fetch).with(:qa_replacement_patterns, nil).and_return(typo_subauth)
      end
      it 'returns default' do
        expect(described_class.extract_subauthority_variable(config: config)).to eq described_class::DEFAULT_SUBAUTH_VARIABLE
      end
    end
  end

  describe '.extract_termid_variable' do
    before do
      custom_termid = { term_id: 'custom_termid' }
      allow(config).to receive(:fetch).with(:qa_replacement_patterns, nil).and_return(custom_termid)
    end
    it 'returns the name of the template variable for passing the term id on to the external authority' do
      expect(described_class.extract_termid_variable(config: config)).to eq 'custom_termid'
    end

    context 'when qa_replacement_patterns is missing' do
      before { allow(config).to receive(:fetch).with(:qa_replacement_patterns, nil).and_return(nil) }
      it 'returns default' do
        expect(described_class.extract_termid_variable(config: config)).to eq described_class::DEFAULT_TERMID_VARIABLE
      end
    end

    context 'when term_id is missing' do
      before do
        typo_termid = { temr_id: 'custom_termid_not_picked_up_due_to_typo' }
        allow(config).to receive(:fetch).with(:qa_replacement_patterns, nil).and_return(typo_termid)
      end
      it 'returns default' do
        expect(described_class.extract_termid_variable(config: config)).to eq described_class::DEFAULT_TERMID_VARIABLE
      end
    end
  end

  describe '.extract_query_variable' do
    before do
      custom_query = { query: 'custom_query' }
      allow(config).to receive(:fetch).with(:qa_replacement_patterns, nil).and_return(custom_query)
    end
    it 'returns the name of the template variable for passing the query on to the external authority' do
      expect(described_class.extract_query_variable(config: config)).to eq 'custom_query'
    end

    context 'when qa_replacement_patterns is missing' do
      before { allow(config).to receive(:fetch).with(:qa_replacement_patterns, nil).and_return(nil) }
      it 'returns default' do
        expect(described_class.extract_query_variable(config: config)).to eq described_class::DEFAULT_QUERY_VARIABLE
      end
    end

    context 'when query is missing' do
      before do
        typo_query = { qeury: 'custom_query_not_picked_up_due_to_typo' }
        allow(config).to receive(:fetch).with(:qa_replacement_patterns, nil).and_return(typo_query)
      end
      it 'returns default' do
        expect(described_class.extract_query_variable(config: config)).to eq described_class::DEFAULT_QUERY_VARIABLE
      end
    end
  end

  describe '.extract_context_map' do
    xit 'returns an instance of context_map' do
      # TODO: pending implementation of context map
      expect(described_class.extract_context_map(config: config)).to be_kind_of Qa::LinkedData::Config::ContextMap
    end

    context 'when missing' do
      before { allow(config).to receive(:fetch).with(:context, nil).and_return(nil) }
      it 'returns nil' do
        expect(described_class.extract_context_map(config: config)).to be_nil
      end
    end
  end

  describe '.extract_default_language' do
    it 'returns list of language codes' do
      expect(described_class.extract_default_language(config: config)).to match_array ['en', 'fr', 'de']
    end

    context 'when missing' do
      before { allow(config).to receive(:fetch).with(:language, nil).and_return(nil) }
      it 'returns nil' do
        expect(described_class.extract_default_language(config: config)).to be_nil
      end
    end

    context 'when language is a string' do
      before { allow(config).to receive(:fetch).with(:language, nil).and_return('en') }
      it 'returns language in an array' do
        expect(described_class.extract_default_language(config: config)).to  match_array ['en']
      end
    end

    context 'when language is an array' do
      before { allow(config).to receive(:fetch).with(:language, nil).and_return(['en', 'fr']) }
      it 'returns the language array' do
        expect(described_class.extract_default_language(config: config)).to  match_array ['en', 'fr']
      end
    end
  end
end
