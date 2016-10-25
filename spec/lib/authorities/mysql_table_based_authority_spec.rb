require 'spec_helper'

describe Qa::Authorities::Local::MysqlTableBasedAuthority do
  let(:language) { Qa::Authorities::Local.subauthority_for("language") }
  let(:language_auth) { Qa::LocalAuthority.find_by(name: 'language') }
  let(:base_relation) { Qa::LocalAuthorityEntry.where(name: 'language') }
  before do
    Qa::Authorities::Local.register_subauthority('language', described_class.to_s)
  end

  describe "::table_name" do
    subject { described_class.table_name }
    it { is_expected.to eq("qa_local_authority_entries") }
  end

  describe "::table_index" do
    subject { described_class.table_index }
    it { is_expected.to eq("index_qa_local_authority_entries_on_lower_label_and_authority") }
  end

  describe "#check_for_index" do
    let(:connection) { ActiveRecord::Base.connection }
    before do
      allow(ActiveRecord::Base).to receive(:connection).and_return(connection)
    end
    context "with no index" do
      before do
        # allow(connection).to receive(:index_name_exists?).and_return(nil)
      end
      it "outputs an error message" do
        expect(Rails.logger).to receive(:error)
        described_class.check_for_index
      end
    end
    context "with index" do
      before do
        allow(connection).to receive(:index_name_exists?).and_return(true)
      end
      it "outputs an error message" do
        expect(Rails.logger).not_to receive(:error)
        described_class.check_for_index
      end
    end
  end

  describe "#search" do
    context "with an empty query string" do
      let(:expected) { [] }
      it "returns no results" do
        expect(Qa::LocalAuthorityEntry).not_to receive(:where)
        expect(language.search("")).to eq(expected)
      end
    end
    context "with at least one matching entry" do
      it "is case insensitive by using lower_lable column" do
        expect(Qa::LocalAuthorityEntry).to receive(:where).with(local_authority: language_auth).and_return(base_relation)
        expect(base_relation).to receive(:where).with("lower_label like ?", "fre%").and_return(base_relation)
        expect(base_relation).to receive(:limit).and_return([])
        language.search("fRe")
      end
    end
  end
end
