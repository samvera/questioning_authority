require 'spec_helper'

describe Qa::Authorities::Discogs do
  describe "#subauthority_for" do
    context "with an invalid sub-authority" do
      it "raises an exception" do
        expect { described_class.subauthority_for("foo") }.to raise_error Qa::InvalidSubAuthority
      end
    end

    context "with a valid sub-authority" do
      it "creates the authority" do
        expect(described_class.subauthority_for("master")).to be_kind_of Qa::Authorities::Discogs::GenericAuthority
      end
    end
  end
end
