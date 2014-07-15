require 'spec_helper'

describe Qa::Authorities::Local do

  let(:authority_a) { Qa::Authorities::Local.new("authority_A") }
  let(:authority_b) { Qa::Authorities::Local.new("authority_B") }
  let(:authority_c) { Qa::Authorities::Local.new("authority_C") }
  let(:authority_d) { Qa::Authorities::Local.new("authority_D") }

  describe "::new" do
    context "without a sub-authority" do
      it "should raise an error is the sub-authority is not provided" do
        lambda { Qa::Authorities::Local.new }.should raise_error
      end
      it "should raise an error is the sub-authority does not exist" do
        lambda { Qa::Authorities::Local.new("foo") }.should raise_error
      end
    end
  end

  describe "#all" do
    let(:expected) { [ { 'id'=> "A1", 'label' => "Abc Term A1" },
                       { 'id' => "A2", 'label'=> "Term A2" },
                       { 'id' => "A3", 'label' => "Abc Term A3" } ] }
    it "should return all the entries" do
      authority_a.all.should eq(expected)
    end
    context "when terms do not have ids" do
      let(:expected) { [ { 'id' => "Term B1", 'label' => "Term B1" },
                         { 'id' => "Term B2", 'label' => "Term B2" },
                         { 'id' => "Term B3", 'label' => "Term B3" } ] }
      it "should set the id to be same as the label" do
        expect(authority_b.all).to eq(expected)
      end
    end
    context "authority YAML file is a list of terms" do
      let(:expected) { [ { 'id' => "Term C1", 'label' => "Term C1" }, 
                         { 'id' => "Term C2", 'label' => "Term C2" },
                         { 'id' => "Term C3", 'label' => "Term C3" } ] }
      it "should use the terms as labels" do
        expect(authority_c.all).to eq(expected)
      end   
    end
    context "YAML file is malformed" do
      it "should raise an error" do
        lambda { authority_d.all }.should raise_error
      end
    end
  end

  describe "#search" do
    context "with an empty query string" do
      let(:expected) { [] }
      it "should return no results" do
        expect(authority_a.search("")).to eq(expected)
      end
    end
    context "with at least one matching entry" do
      let(:expected) { [ { 'id' => "A1", 'label' => "Abc Term A1" },
                         { 'id' => "A3", 'label' => "Abc Term A3" } ] }
      it "should return only entries matching the query term" do
        expect(authority_a.search("Abc")).to eq(expected)
      end
      it "should match parts of words in the middle of the term" do
        expect(authority_a.search("Term A1")).to eq([{"id"=>"A1", "label"=>"Abc Term A1"}])
      end
      it "should be case insensitive" do
        expect(authority_a.search("aBc")).to eq(expected)
      end
    end
    context "with no matching entries" do
      let(:expected) { [] }
      it "should return an empty array" do
        expect(authority_a.search("def")).to eq(expected)
      end
    end
  end
  
  describe "#find" do
    context "source is a hash" do
      let(:id) { "A2" }
      let(:expected) { { 'id' => "A2", 'term' => "Term A2", 'active' => false } }
      it "should return the full term record" do
        record = authority_a.find(id)
        expect(record).to be_a HashWithIndifferentAccess
        expect(record).to eq(expected)
      end
    end
    context "source is a list" do
      it "should be indifferent access" do
        record = authority_c.find("Term C1")
        expect(record).to be_a HashWithIndifferentAccess
      end
    end
    context "term does not exist" do
      let(:id) { "NonID" }
      let(:expected) { {} }
      it "should return an empty hash" do
        expect(authority_a.find(id)).to eq(expected)
      end
    end
    context "on a sub-authority" do
      it "should return the full term record" do
        record = authority_a.find("A2")
        expect(record).to be_a HashWithIndifferentAccess
        expect(record).to eq('id' => "A2", 'term' => "Term A2", 'active' => false)
      end
    end
  end

end
