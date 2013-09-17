require 'spec_helper'

describe Authorities::Lcsh do

  it "should query LOC for terms" do
    terms = Authorities::Lcsh.new "ABBA"
    terms.results.should include "ABBA (Musical group)"
  end

end