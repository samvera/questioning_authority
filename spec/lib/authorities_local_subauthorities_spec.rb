require 'spec_helper'

describe Qa::Authorities::LocalSubauthority do

  before do
    class TestClass
      include Qa::Authorities::LocalSubauthority
    end
  end

  after { Object.send(:remove_const, :TestClass) }

  let(:test) { TestClass.new }

  before { @original_path = AUTHORITIES_CONFIG[:local_path] }
  after { AUTHORITIES_CONFIG[:local_path] = @original_path }

  describe "#subauthorities_path" do
    before { AUTHORITIES_CONFIG[:local_path] = path }
    context "configured with a full path" do
      let(:path) { "/full/path" }

      it "returns a full path" do
        expect(test.subauthorities_path).to eq(path)
      end
    end

    context "configured with a relative path" do
      let(:path) { "relative/path" }

      it "returns a path relative to the Rails applicaition" do
        expect(test.subauthorities_path).to eq(File.join(Rails.root, path))
      end
    end
  end

  describe "#names" do
    it "returns a list of yaml files" do
      expect(test.names).to include("authority_A", "authority_B", "authority_C", "authority_D", "states")
    end

    context "when the path doesn't exist" do
      before { AUTHORITIES_CONFIG[:local_path] = '/foo/bar' }

      it "raises an error" do
        expect { test.names }.to raise_error Qa::ConfigDirectoryNotFound
      end
    end
  end

end
