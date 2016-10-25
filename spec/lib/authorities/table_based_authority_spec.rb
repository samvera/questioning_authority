require 'spec_helper'

describe Qa::Authorities::Local::TableBasedAuthority do
  let(:language) { Qa::Authorities::Local.subauthority_for("language") }
  let(:subj) { Qa::Authorities::Local.subauthority_for("subject") }

  let(:language_auth) { Qa::LocalAuthority.find_or_create_by(name: 'language') }
  let(:alternate_auth) { Qa::LocalAuthority.find_or_create_by(name: 'subject') }
  before do
    Qa::Authorities::Local.register_subauthority('language', described_class.to_s)
    Qa::Authorities::Local.register_subauthority('subject', described_class.to_s)
    Qa::LocalAuthorityEntry.create(local_authority: language_auth, label: 'French', uri: 'http://id.loc.gov/vocabulary/languages/fre')
    Qa::LocalAuthorityEntry.create(local_authority: language_auth, label: 'Uighur', uri: 'http://id.loc.gov/vocabulary/languages/uig')
    Qa::LocalAuthorityEntry.create(local_authority: alternate_auth, label: 'French', uri: 'http://example.com/french')
  end

  describe "::table_name" do
    subject { described_class.table_name }
    it { is_expected.to eq("qa_local_authority_entries") }
  end

  describe "::table_index" do
    subject { described_class.table_index }
    it { is_expected.to eq("index_qa_local_authority_entries_on_lower_label") }
  end

  describe "#all" do
    let(:expected) { [{ 'id' => "A1", 'label' => "Abc Term A1" },
                      { 'id' => "A2", 'label' => "Term A2" },
                      { 'id' => "A3", 'label' => "Abc Term A3" }] }
    it "returns all the entries" do
      expect(language.all).to eq [
        { "id" => "http://id.loc.gov/vocabulary/languages/fre", "label" => "French" },
        { "id" => "http://id.loc.gov/vocabulary/languages/uig", "label" => "Uighur" }
      ]
    end
  end

  describe "#search" do
    context "with an empty query string" do
      let(:expected) { [] }
      it "returns no results" do
        expect(language.search("")).to eq(expected)
      end
    end
    context "with at least one matching entry" do
      it "is case insensitive" do
        expect(language.search("fRe")).to eq [{ "id" => "http://id.loc.gov/vocabulary/languages/fre", "label" => "French" }]
      end
    end

    context "with no matching entries" do
      it "returns an empty array" do
        expect(language.search("def")).to be_empty
      end
    end
  end

  describe "#find" do
    context "term exists" do
      it "returns the full term record" do
        record = language.find('http://id.loc.gov/vocabulary/languages/fre')
        expect(record).to be_a HashWithIndifferentAccess
        expect(record).to eq('id' => "http://id.loc.gov/vocabulary/languages/fre",
                             'label' => "French")
      end
    end
    context "term does not exist" do
      let(:id) { "NonID" }
      let(:expected) { {} }
      it "returns an empty hash" do
        expect(language.find('http://id.loc.gov/vocabulary/languages/eng')).to be_nil
      end
    end
  end
end
