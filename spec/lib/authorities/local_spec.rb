require 'spec_helper'

describe Qa::Authorities::Local do

  describe "new" do
    it "should raise an error" do
      expect { Qa::Authorities::Local.new }.to raise_error
    end
  end

  describe ".factory" do
    context "without a sub-authority" do
      it "should raise an error is the sub-authority is not provided" do
        expect { Qa::Authorities::Local.factory }.to raise_error
      end
      it "should raise an error is the sub-authority does not exist" do
        expect { Qa::Authorities::Local.factory("foo") }.to raise_error
      end
    end

    context "with a sub authority" do
      subject { Qa::Authorities::Local.factory("authority_A") }
      it "should return a file authority" do
        expect(subject).to be_kind_of Qa::Authorities::Local::FileBasedAuthority
      end
    end
  end
end
