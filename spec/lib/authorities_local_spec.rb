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
    
    it "should return all the entries" do
      authorities = Authorities::Local.new("", "authority_A")
      authorities.parse_authority_response.should include "Term A2"
    end
    
  end
  
  context "retrieve a subset of entries for a local sub_authority" do
    
    it "should return only entries matching the query term" do
      authorities = Authorities::Local.new("Abc", "authority_A")
      authorities.parse_authority_response.should include "Abc Term A1"
      authorities.parse_authority_response.should_not include "Term A2"
    end
    
  end

end