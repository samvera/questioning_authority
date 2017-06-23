require 'spec_helper'

describe Qa::Authorities::Local::FileBasedAuthority do
  let(:authority_a) { Qa::Authorities::Local.subauthority_for("authority_A") }
  let(:authority_b) { Qa::Authorities::Local.subauthority_for("authority_B") }
  let(:authority_c) { Qa::Authorities::Local.subauthority_for("authority_C") }
  let(:authority_d) { Qa::Authorities::Local.subauthority_for("authority_D") }

  describe "#all" do
    let(:expected) { [{ 'id' => "A1", 'label' => "Abc Term A1", 'active' => true },
                      { 'id' => "A2", 'label' => "Term A2", 'active' => false },
                      { 'id' => "A3", 'label' => "Abc Term A3", 'active' => true }] }
    it "returns all the entries" do
      expect(authority_a.all).to eq(expected)
    end
    context "when terms do not have ids" do
      let(:expected) { [{ 'id' => "Term B1", 'label' => "Term B1", 'active' => true },
                        { 'id' => "Term B2", 'label' => "Term B2", 'active' => true },
                        { 'id' => "Term B3", 'label' => "Term B3", 'active' => true }] }
      it "sets the id to be same as the label" do
        expect(authority_b.all).to eq(expected)
      end
    end
    context "authority YAML file is a list of terms" do
      let(:expected) { [{ 'id' => "Term C1", 'label' => "Term C1", 'active' => true },
                        { 'id' => "Term C2", 'label' => "Term C2", 'active' => true },
                        { 'id' => "Term C3", 'label' => "Term C3", 'active' => true }] }
      it "uses the terms as labels" do
        expect(authority_c.all).to eq(expected)
      end
    end
    context "YAML file is malformed" do
      it "raises an error" do
        expect { authority_d.all }.to raise_error Psych::SyntaxError
      end
    end
  end

  describe "#search" do
    context "with an empty query string" do
      let(:expected) { [] }
      it "returns no results" do
        expect(authority_a.search("")).to eq(expected)
      end
    end
    context "with at least one matching entry" do
      let(:expected) { [{ 'id' => "A1", 'label' => "Abc Term A1" },
                        { 'id' => "A3", 'label' => "Abc Term A3" }] }
      it "returns only entries matching the query term" do
        expect(authority_a.search("Abc")).to eq(expected)
      end
      it "matches parts of words in the middle of the term" do
        expect(authority_a.search("Term A1")).to eq([{ "id" => "A1", "label" => "Abc Term A1" }])
      end
      it "is case insensitive" do
        expect(authority_a.search("aBc")).to eq(expected)
      end
    end
    context "with no matching entries" do
      let(:expected) { [] }
      it "returns an empty array" do
        expect(authority_a.search("def")).to eq(expected)
      end
    end
  end

  describe "#find" do
    context "source is a hash" do
      let(:id) { "A2" }
      let(:expected) { { 'id' => "A2", 'term' => "Term A2", 'active' => false } }
      it "returns the full term record" do
        record = authority_a.find(id)
        expect(record).to be_a HashWithIndifferentAccess
        expect(record).to eq(expected)
      end
    end
    context "source is a list" do
      it "is indifferent access" do
        record = authority_c.find("Term C1")
        expect(record).to be_a HashWithIndifferentAccess
      end
    end
    context "term does not exist" do
      let(:id) { "NonID" }
      let(:expected) { {} }
      it "returns an empty hash" do
        expect(authority_a.find(id)).to eq(expected)
      end
    end
    context "on a sub-authority" do
      it "returns the full term record" do
        record = authority_a.find("A2")
        expect(record).to be_a HashWithIndifferentAccess
        expect(record).to eq('id' => "A2", 'term' => "Term A2", 'active' => false)
      end
    end
  end
end
