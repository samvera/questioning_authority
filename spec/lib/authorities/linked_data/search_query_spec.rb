require 'spec_helper'

RSpec.describe Qa::Authorities::LinkedData::SearchQuery do
  describe "#sort_search_results" do
    let(:config) { Qa::Authorities::LinkedData::Config.new(auth_name).search }
    let(:instance) { described_class.new(config) }

    let(:term_a) { "alpha" }
    let(:term_b) { "bravo" }
    let(:term_c) { "charlie" }
    let(:term_d) { "delta" }

    context 'when sort predicate is NOT specified in configuration' do
      let(:auth_name) { :LOD_MIN_CONFIG }

      it "does not change order" do
        json_results = [{ label: "[#{term_b}, #{term_c}]", sort: [term_b, term_c] }, { label: "[#{term_b}, #{term_d}]", sort: [term_b, term_d] }, { label: "[#{term_b}, #{term_a}]", sort: [term_b, term_a] }]
        expect(instance.send(:sort_search_results, json_results)).to eq json_results
      end
    end

    context 'when sort predicate is specified in configuration' do
      let(:auth_name) { :LOD_SORT }

      context "when sort term is empty" do
        context "for all" do
          it "does not change order" do
            json_results = [{ label: "[#{term_b}]", sort: [""] }, { label: "[#{term_a}]", sort: [""] }, { label: "[#{term_c}]", sort: [""] }]
            expect(instance.send(:sort_search_results, json_results)).to eq json_results
          end
        end

        context "for one" do
          it "puts empty first" do
            json_results = [{ label: "[#{term_b}]", sort: [""] }, { label: "[#{term_c}]", sort: [term_c] }, { label: "[#{term_a}]", sort: [term_a] }]
            expected_results = [{ label: "[#{term_b}]" }, { label: "[#{term_a}]" }, { label: "[#{term_c}]" }]
            expect(instance.send(:sort_search_results, json_results)).to eq expected_results
          end
        end
      end

      context "when sort term is single value" do
        context "for all" do
          it "sorts on the single value" do
            json_results = [{ label: "[#{term_b}]", sort: [term_b] }, { label: "[#{term_c}]", sort: [term_c] }, { label: "[#{term_a}]", sort: [term_a] }]
            expected_results = [{ label: "[#{term_a}]" }, { label: "[#{term_b}]" }, { label: "[#{term_c}]" }]
            expect(instance.send(:sort_search_results, json_results)).to eq expected_results
          end
        end
      end

      context "when first sort term is same" do
        it "sorts on second sort term" do
          json_results = [{ label: "[#{term_b}, #{term_c}]", sort: [term_b, term_c] }, { label: "[#{term_b}, #{term_d}]", sort: [term_b, term_d] }, { label: "[#{term_b}, #{term_a}]", sort: [term_b, term_a] }]
          expected_results = [{ label: "[#{term_b}, #{term_a}]" }, { label: "[#{term_b}, #{term_c}]" }, { label: "[#{term_b}, #{term_d}]" }]
          expect(instance.send(:sort_search_results, json_results)).to eq expected_results
        end
      end

      context "when different number of sort terms" do
        context "and initial terms match" do
          it "puts shorter set of terms before longer set" do
            json_results = [{ label: "[#{term_b}, #{term_c}]", sort: [term_b, term_c] }, { label: "[#{term_b}]", sort: [term_b] }, { label: "[#{term_b}, #{term_a}]", sort: [term_b, term_a] }]
            expected_results = [{ label: "[#{term_b}]" }, { label: "[#{term_b}, #{term_a}]" }, { label: "[#{term_b}, #{term_c}]" }]
            expect(instance.send(:sort_search_results, json_results)).to eq expected_results
          end
        end

        context "and a difference happens before end of term sets" do
          it "stops ordering as soon as a difference is found" do
            json_results = [{ label: "[#{term_b}, #{term_d}, #{term_c}]", sort: [term_b, term_d, term_c] }, { label: "[#{term_a}, #{term_c}]", sort: [term_a, term_c] }, { label: "[#{term_b}, #{term_d}, #{term_a}]", sort: [term_b, term_d, term_a] }]
            expected_results = [{ label: "[#{term_a}, #{term_c}]" }, { label: "[#{term_b}, #{term_d}, #{term_a}]" }, { label: "[#{term_b}, #{term_d}, #{term_c}]" }]
            expect(instance.send(:sort_search_results, json_results)).to eq expected_results
          end
        end
      end
    end
  end
end
