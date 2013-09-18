require 'spec_helper'

describe Authorities::Local do

  before do
    AUTHORITIES_CONFIG[:local_path] = File.join('spec', 'fixtures', 'authorities')
  end
  
  context "valid local sub_authorities" do
    
    it "should validate the sub_authority" do
      Authorities::Local.sub_authorities.should include "authority_A"
      Authorities::Local.sub_authorities.should include "authority_B"
    end
    
  end

  context "retrieve all entries for a local sub_authority" do
    
    let(:expected) { [ { :id => "A1", :label => "Abc Term A1" }, { :id => "A2", :label => "Term A2" }, { :id => "A3", :label => "Abc Term A3" } ].to_json }

    it "should return all the entries" do
      authorities = Authorities::Local.new("", "authority_A")
      authorities.parse_authority_response.should == expected
    end
    
  end
  
  context "retrieve a subset of entries for a local sub_authority" do

    let(:expected) { [ { :id => "A1", :label => "Abc Term A1" }, { :id => "A3", :label => "Abc Term A3" } ].to_json }
    
    it "should return only entries matching the query term" do
      authorities = Authorities::Local.new("Abc", "authority_A")
      authorities.parse_authority_response.should == expected
    end
    
  end

end