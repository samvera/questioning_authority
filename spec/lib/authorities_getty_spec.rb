require 'spec_helper'

describe Qa::Authorities::Getty do

  describe "#new" do
    context "without a sub-authority" do
      it "should raise an exception" do
        expect { described_class.new }.to raise_error
      end
    end
    context "with an invalid sub-authority" do
      it "should raise an exception" do
        expect { described_class.new("foo") }.to raise_error
      end
    end
    context "with a valid sub-authority" do
      it "should create the authority" do
        expect(described_class.new("aat")).to be_kind_of described_class
      end
    end
  end

  let(:authority) { described_class.new("aat") }
  describe "#build_query_url" do
    subject { authority.build_query_url("foo") }
    it { is_expected.to  match /^http:\/\/vocab\.getty\.edu\// }
  end

  describe "#find_url" do
    subject { authority.find_url("300053264") }
    it { is_expected.to eq "http://vocab.getty.edu/aat/300053264.json" }
  end

  describe "#search" do
    context "authorities" do
      before do
        stub_request(:get, /vocab\.getty\.edu.*/).
            with(:headers => {'Accept'=>'application/json'}).
            to_return(:body => webmock_fixture("aat-response.txt"), :status => 200)
      end

      subject { authority.search('whatever') }

      it "should have id and label keys" do
        expect(subject.first).to eq("id" => 'http://vocab.getty.edu/aat/300053264', "label" => "photocopying")
        expect(subject.last).to eq("id" => 'http://vocab.getty.edu/aat/300265560', "label" => "photoscreenprints")
        expect(subject.size).to eq(10)
      end
    end
  end

  describe "#untaint" do
    subject { authority.untaint(value) }

    context "with a good string" do
      let(:value) { 'Water-color paint' }
      it { is_expected.to eq 'Water-color paint' }
    end

    context "bad stuff" do
      let(:value) { './"' }
      it { is_expected.to eq '' }
    end
  end

  describe "#find" do
    context "using a subject id" do
      before do
        stub_request(:get, "http://vocab.getty.edu/aat/300265560.json").
          with(headers: { 'Accept'=>'application/json' }).
          to_return(status: 200, body: webmock_fixture("getty-aat-find-response.json"))
      end
      subject { described_class.new("aat").find("300265560") }

      it "returns the complete record for a given subject" do
        expect(subject['results']['bindings'].size).to eq 189
        expect(subject['results']['bindings']).to all(have_key('Subject'))
        expect(subject['results']['bindings']).to all(have_key('Predicate'))
        expect(subject['results']['bindings']).to all(have_key('Object'))
      end
    end
  end

end

