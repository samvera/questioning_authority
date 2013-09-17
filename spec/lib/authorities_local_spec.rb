require 'spec_helper'

describe Authorities::Local do

  context "retrieve all entries for a local sub_authority" do
    
    it "should validate the sub_authority" do
      Authorities::Local.sub_authorities.should include "school"
    end
    
    it "should return all the entries" do
      authorities = Authorities::Local.new("", "school")
      authorities.parse_authority_response.should include "School of Business"
    end
    
  end
  
  context "retrieve a subset of entries for a local sub_authority" do
    
    it "should return only entries matching the query term" do
      authorities = Authorities::Local.new("School", "school")
      authorities.parse_authority_response.should include "School of Business"
      authorities.parse_authority_response.should_not include "College of Arts and Sciences"
    end
    
  end

end