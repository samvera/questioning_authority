require 'spec_helper'

describe Qa::Authorities::Getty do
  describe "#new" do
    it "raises an exception" do
      expect { described_class.new }.to raise_error RuntimeError, "Initializing with as sub authority is removed. use Module.subauthority_for(nil) instead"
    end
  end

  describe "#subauthority_for" do
    context "without a sub-authority" do
      it "raises an exception" do
        expect { described_class.subauthority_for }.to raise_error ArgumentError
      end
    end

    context "with an invalid sub-authority" do
      it "raises an exception" do
        expect { described_class.subauthority_for("foo") }.to raise_error Qa::InvalidSubAuthority
      end
    end

    context "with a valid sub-authority" do
      it "creates the authority" do
        expect(described_class.subauthority_for("aat")).to be_kind_of Qa::Authorities::Getty::AAT
      end
    end
  end
end
