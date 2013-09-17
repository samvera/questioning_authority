require 'spec_helper'

describe Authorities::Local do

  context "retrieve all entries for a local authority" do
    
    it "should return all the entries" do
      terms = Authorities::Local.new("", "school")
      terms.results.should include "School of Business"
    end
    
  end

end