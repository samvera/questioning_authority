require 'spec_helper'

describe Qa::Authorities::Local do
  describe "new" do
    it "raises an error" do
      expect { described_class.new }.to raise_error RuntimeError, "Initializing with as sub authority is removed. use Module.subauthority_for(nil) instead"
    end
  end

  describe "#subauthorities_path" do
    before do
      @original_path = described_class.config[:local_path]
      described_class.config[:local_path] = path
    end
    after { described_class.config[:local_path] = @original_path }

    context "configured with a full path" do
      let(:path) { "/full/path" }

      it "returns a full path" do
        expect(described_class.subauthorities_path).to eq(path)
      end
    end

    context "configured with a relative path" do
      let(:path) { "relative/path" }

      it "returns a path relative to the Rails applicaition" do
        expect(described_class.subauthorities_path).to eq(File.join(Rails.root, path))
      end
    end
  end

  describe "#names" do
    it "returns a list of yaml files" do
      expect(described_class.names).to include("authority_A", "authority_B", "authority_C", "authority_D", "states")
    end

    context "when the path doesn't exist" do
      before do
        @original_path = described_class.config[:local_path]
        described_class.config[:local_path] = '/foo/bar'
      end
      after { described_class.config[:local_path] = @original_path }

      it "raises an error" do
        expect { described_class.names }.to raise_error Qa::ConfigDirectoryNotFound
      end
    end
  end

  describe ".subauthority_for" do
    context "without a sub-authority" do
      it "raises an error is the sub-authority is not provided" do
        expect { described_class.subauthority_for }.to raise_error ArgumentError
      end
      it "raises an error is the sub-authority does not exist" do
        expect { described_class.subauthority_for("foo") }.to raise_error Qa::InvalidSubAuthority
      end
    end

    context "with a sub authority" do
      subject { described_class.subauthority_for("authority_A") }
      it "returns a file authority" do
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
