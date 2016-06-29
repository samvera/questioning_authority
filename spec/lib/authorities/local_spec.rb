require 'spec_helper'

describe Qa::Authorities::Local do

  describe "new" do
    it "should raise an error" do
      expect { described_class.new }.to raise_error RuntimeError, "Initializing with as sub authority is removed. use Module.subauthority_for(nil) instead"
    end
  end

  describe ".subauthority_for" do
    context "without a sub-authority" do
      it "should raise an error is the sub-authority is not provided" do
        expect { described_class.subauthority_for }.to raise_error ArgumentError
      end
      it "should raise an error is the sub-authority does not exist" do
        expect { described_class.subauthority_for("foo") }.to raise_error Qa::InvalidSubAuthority
      end
    end

    context "with a sub authority" do
      subject { described_class.subauthority_for("authority_A") }
      it "should return a file authority" do
        expect(subject).to be_kind_of Qa::Authorities::Local::FileBasedAuthority
      end
    end
  end

  describe ".register" do
    before do
      class SolrAuthority
        def initialize(one)
        end
      end
      described_class.register_subauthority('new_sub', 'SolrAuthority')
    end

    after { Object.send(:remove_const, :SolrAuthority) }

    it "adds an entry to subauthorities" do
      expect(described_class.subauthorities).to include 'new_sub'
    end

    it "creates authorities of the proper type" do
      expect(described_class.subauthority_for('new_sub')).to be_kind_of SolrAuthority
    end
  end
end
