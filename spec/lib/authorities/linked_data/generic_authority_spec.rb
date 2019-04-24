require 'spec_helper'

RSpec.describe Qa::Authorities::LinkedData::GenericAuthority do
  describe '#new' do
    context 'without an authority' do
      it 'raises an exception' do
        expect { described_class.new }.to raise_error ArgumentError, /wrong number of arguments/
      end
    end
    context 'with an invalid authority' do
      it 'raises an exception' do
        expect { described_class.new(:FOO) }.to raise_error Qa::InvalidLinkedDataAuthority, /Unable to initialize linked data authority 'FOO'/
      end
    end
    context 'with a valid authority' do
      it 'creates the authority' do
        expect(described_class.new(:OCLC_FAST)).to be_kind_of described_class
      end
    end
  end

  context 'testing delegated method' do
    let(:full_authority) { described_class.new(:LOD_FULL_CONFIG) }
    let(:min_authority) { described_class.new(:LOD_MIN_CONFIG) }
    let(:search_only_authority) { described_class.new(:LOD_SEARCH_ONLY_CONFIG) }
    let(:term_only_authority) { described_class.new(:LOD_TERM_ONLY_CONFIG) }

    describe '#supports_search?' do
      it 'returns false if search is NOT configured' do
        expect(term_only_authority.supports_search?).to eq false
      end
      it 'returns true if search is configured' do
        expect(full_authority.supports_search?).to eq true
      end
    end

    describe '#search_subauthorities?' do
      it 'returns false if only term configuration is defined' do
        expect(term_only_authority.search_subauthorities?).to eq false
      end
      it 'returns false if the configuration does NOT define subauthorities' do
        expect(min_authority.search_subauthorities?).to eq false
      end
      it 'returns true if the configuration defines subauthorities' do
        expect(full_authority.search_subauthorities?).to eq true
      end
    end

    describe '#search_subauthority?' do
      it 'returns false if only term configuration is defined' do
        expect(term_only_authority.search_subauthority?('fake_subauth')).to eq false
      end
      it 'returns false if there are no subauthorities configured' do
        expect(min_authority.search_subauthority?('fake_subauth')).to eq false
      end
      it 'returns false if the requested subauthority is NOT configured' do
        expect(full_authority.search_subauthority?('fake_subauth')).to eq false
      end
      it 'returns true if the requested subauthority is configured' do
        expect(full_authority.search_subauthority?('search_sub2_key')).to eq true
      end
    end

    describe '#supports_term?' do
      it 'returns false if term is NOT configured' do
        expect(search_only_authority.supports_term?).to eq false
      end
      it 'returns true if term is configured' do
        expect(full_authority.supports_term?).to eq true
      end
    end

    describe '#term_subauthorities?' do
      it 'returns false if only search configuration is defined' do
        expect(search_only_authority.term_subauthorities?).to eq false
      end
      it 'returns false if the configuration does NOT define subauthorities' do
        expect(min_authority.term_subauthorities?).to eq false
      end
      it 'returns true if the configuration defines subauthorities' do
        expect(full_authority.term_subauthorities?).to eq true
      end
    end

    describe '#term_subauthority?' do
      it 'returns false if only search configuration is defined' do
        expect(search_only_authority.term_subauthority?('fake_subauth')).to eq false
      end
      it 'returns false if there are no subauthorities configured' do
        expect(min_authority.term_subauthority?('fake_subauth')).to eq false
      end
      it 'returns false if the requested subauthority is NOT configured' do
        expect(full_authority.term_subauthority?('fake_subauth')).to eq false
      end
      it 'returns true if the requested subauthority is configured' do
        expect(full_authority.term_subauthority?('term_sub2_key')).to eq true
      end
    end

    describe '#term_id_expects_id?' do
      it 'returns false if term_id specifies a URI is required' do
        expect(min_authority.term_id_expects_id?).to eq false
      end
      it 'returns true if term_id specifies an ID is required' do
        expect(full_authority.term_id_expects_id?).to eq true
      end
    end

    describe '#term_id_expects_uri?' do
      it 'returns false if term_id specifies a ID is required' do
        expect(full_authority.term_id_expects_uri?).to eq false
      end
      it 'returns true if term_id specifies an URI is required' do
        expect(min_authority.term_id_expects_uri?).to eq true
      end
    end

    describe '#search' do
      it 'responds to delegated search method' do
        expect(min_authority).to respond_to :search
      end
    end

    describe '#find' do
      it 'responds to delegated search method' do
        expect(min_authority).to respond_to :find
      end
    end

    describe '#load_authorities' do
      it 'responds to delegated search method' do
        expect(min_authority).to respond_to :load_authorities
      end
    end

    describe '#authority_names' do
      it 'responds to delegated search method' do
        expect(min_authority).to respond_to :authority_names
      end
    end
  end

  context 'testing service methods' do
    let(:min_authority) { described_class.new(:LOD_MIN_CONFIG) }

    describe '#authorities_service' do
      it 'returns Qa::LinkedData::AuthorityService as the authorities service' do
        expect(min_authority.authorities_service).to eq Qa::LinkedData::AuthorityService
      end
    end

    describe '#search_service' do
      it 'returns Qa::Authorities::LinkedData::SearchQuery as the search service' do
        expect(min_authority.search_service).to be_kind_of Qa::Authorities::LinkedData::SearchQuery
      end
    end

    describe '#item_service' do
      it 'returns Qa::Authorities::LinkedData::FindTerm as the item service' do
        expect(min_authority.item_service).to be_kind_of Qa::Authorities::LinkedData::FindTerm
      end
    end
  end
end
