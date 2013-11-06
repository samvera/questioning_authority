require 'spec_helper'

describe Qa::Authorities::Local do

  before do
    AUTHORITIES_CONFIG[:local_path] = local_authorities_path
  end

  context "valid local sub_authorities" do
    it "should validate the sub_authority" do
      Qa::Authorities::Local.sub_authorities.should include "authority_A"
      Qa::Authorities::Local.sub_authorities.should include "authority_B"
    end    

    it "should return a sub_authority" do
      expect { Qa::Authorities::Local.sub_authority('authority_Z')}.to raise_error ArgumentError, "Invalid sub-authority 'authority_Z'"
      expect(Qa::Authorities::Local.sub_authority('authority_A')).to be_kind_of Qa::Authorities::Subauthority
    end
  end

  context "retrieve all entries for a local sub_authority" do
    let(:expected) { [ { 'id'=> "A1", 'label' => "Abc Term A1" },
                       { 'id' => "A2", 'label'=> "Term A2" },
                       { 'id' => "A3", 'label' => "Abc Term A3" } ] }
    it "should return all the entries" do
      authorities = Qa::Authorities::Local.new
      authorities.search("", "authority_A")
      expect(authorities.response).to eq(expected)
    end
  end

  context "a malformed authority file " do
    it "should raise an error" do
      authorities = Qa::Authorities::Local.new
      expect{ authorities.search("", "authority_D") }.to raise_error Psych::SyntaxError
    end
  end
  
  context "retrieve a subset of entries for a local sub_authority" do

    context "at least one matching entry" do
      let(:expected) { [ { 'id' => "A1", 'label' => "Abc Term A1" },
                         { 'id' => "A3", 'label' => "Abc Term A3" } ] }
      it "should return only entries matching the query term" do
        authorities = Qa::Authorities::Local.new
        authorities.search("Abc", "authority_A")
        expect(authorities.response).to eq(expected)
      end
    end
    
    context "no matching entries" do
      let(:expected) { [] }
      it "should return an empty array" do
        authorities = Qa::Authorities::Local.new
        authorities.search("def", "authority_A")
        expect(authorities.response).to eq(expected)
      end
    end
    
    context "search not case-sensitive" do
      let(:expected) { [ { 'id' => "A1", 'label' => "Abc Term A1" },
                         { 'id' => "A3", 'label' => "Abc Term A3" } ] }
      it "should return entries matching the query term without regard to case" do
        authorities = Qa::Authorities::Local.new
        authorities.search("aBc", "authority_A")
        expect(authorities.response).to eq(expected)
      end
    end
    
  end
  
  context "retrieve full record for term" do

    let(:authorities) { Qa::Authorities::Local.new }
    
    context "source is a hash" do
      let(:id) { "A2" }
      let(:expected) { { 'id' => "A2", 'term' => "Term A2", 'active' => false } }
      it "should return the full term record" do
        record = authorities.get_full_record(id, "authority_A")
        expect(record).to be_a HashWithIndifferentAccess
        expect(record).to eq(expected)
      end
    end
    context "source is a list" do
      it "should be indifferent access" do
        record = authorities.get_full_record('Term C1', "authority_C")
        expect(record).to be_a HashWithIndifferentAccess
      end
    end
    
    context "term does not exist" do
      let(:id) { "NonID" }
      let(:expected) { {} }
      it "should return an empty hash" do
        expect(authorities.get_full_record(id, "authority_A")).to eq(expected)
      end
    end

  end
  
  context "term does not an id" do
    let(:authorities) { Qa::Authorities::Local.new }
    let(:expected) { [ { 'id' => "Term B1", 'label' => "Term B1" },
                       { 'id' => "Term B2", 'label' => "Term B2" },
                       { 'id' => "Term B3", 'label' => "Term B3" } ] }
    it "should set the id to be same as the label" do
      expect(authorities.search("", "authority_B")).to eq(expected)
    end
  end
  
  context "authority YAML is a list of terms" do
    let(:authorities) { Qa::Authorities::Local.new }
    let(:expected) { [ { 'id' => "Term C1", 'label' => "Term C1" }, 
                       { 'id' => "Term C2", 'label' => "Term C2" },
                       { 'id' => "Term C3", 'label' => "Term C3" } ] }

    it "should use the terms as labels" do
      expect(authorities.search("", "authority_C")).to eq(expected)
    end

  end

end
