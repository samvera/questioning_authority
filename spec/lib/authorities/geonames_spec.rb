require 'spec_helper'

describe Qa::Authorities::Geonames do
  before do
    described_class.username = 'dummy'
  end

  let(:authority) { described_class.new }

  describe "#build_query_url" do
    subject { authority.build_query_url("foo") }
    it { is_expected.to eq 'http://api.geonames.org/searchJSON?q=foo&username=dummy&maxRows=10' }
  end

  describe "#find_url" do
    subject { authority.find_url("1028772") }
    it { is_expected.to eq "http://www.geonames.org/getJSON?geonameId=1028772&username=dummy" }
  end

  describe "#search" do
    context "authorities" do
      before do
        stub_request(:get, /api\.geonames\.org.*/)
          .to_return(body: webmock_fixture("geonames-response.json"), status: 200)
      end

      subject { authority.search('whatever') }

      context "with default label" do
        it "has id and label keys" do
          expect(subject.first).to eq("id" => 'http://sws.geonames.org/2088122/',
                                      "label" => "Port Moresby, National Capital, Papua New Guinea")
          expect(subject.last).to eq("id" => 'http://sws.geonames.org/377039/',
                                     "label" => "Port Sudan, Red Sea, Sudan")
          expect(subject.size).to eq(10)
        end
      end

      context "with custom label" do
        before do
          @original_label = described_class.label
          described_class.label = -> (item) { item['name'] }
        end
        after do
          described_class.label = @original_label
        end
        it "uses the lambda" do
          expect(subject.first['label']).to eq("Port Moresby")
        end
      end

      context "when username isn't set" do
        before { described_class.username = nil }
        it "logs an error" do
          expect(Rails.logger).to receive(:error).with('Questioning Authority tried to call geonames, but no username was set')
          expect(subject).to be_empty
        end
      end
    end
  end

  describe "#untaint" do
    subject { authority.untaint(value) }

    context "with a good string" do
      let(:value) { 'Cawood' }
      it { is_expected.to eq 'Cawood' }
    end

    context "bad stuff" do
      let(:value) { './"' }
      it { is_expected.to eq '' }
    end
  end

  describe "#find" do
    context "using a subject id" do
      before do
        stub_request(:get, "http://www.geonames.org/getJSON?geonameId=2088122&username=dummy")
          .to_return(status: 200, body: webmock_fixture("geonames-find-response.json"))
      end
      subject { authority.find("2088122") }

      it "returns the complete record for a given subject" do
        expect(subject['geonameId']).to eq 2_088_122
        expect(subject['name']).to eq "Port Moresby"
      end
    end
  end
end
