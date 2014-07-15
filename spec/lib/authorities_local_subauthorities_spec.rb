require 'spec_helper'

describe Qa::Authorities::LocalSubauthority do

  let :test do
    class TestClass
      include Qa::Authorities::LocalSubauthority
    end
    TestClass.new
  end

  describe "#sub_authorities_path" do
    before do
      @original_path = AUTHORITIES_CONFIG[:local_path]
    end
    after do
      AUTHORITIES_CONFIG[:local_path] = @original_path
    end
    context "configured with a full path" do
      before do
        AUTHORITIES_CONFIG[:local_path] = "/full/path"
      end
      it "returns a full path" do
        test.sub_authorities_path.should == AUTHORITIES_CONFIG[:local_path]
      end
    end
    context "configured with a relative path" do
      before do
        AUTHORITIES_CONFIG[:local_path] = "relative/path"
      end
      it "returns a path relative to the Rails applicaition" do
        test.sub_authorities_path.should == File.join(Rails.root, AUTHORITIES_CONFIG[:local_path])
      end
    end
  end

  describe "#names" do  
    it "returns a list of yaml files" do
      test.names.should include("authority_A", "authority_B", "authority_C", "authority_D", "states")
    end
  end

end
