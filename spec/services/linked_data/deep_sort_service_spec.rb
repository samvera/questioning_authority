require 'spec_helper'

RSpec.describe Qa::LinkedData::DeepSortService do
  describe "#deep_sort" do
    subject { described_class.new(the_array, :sort, preferred_language).sort }

    let(:preferred_language) { nil }

    context 'as numeric sort' do
      context 'when sort values are integers' do
        let(:term_1) { RDF::Literal.new(1) }
        let(:term_2) { RDF::Literal.new(15) }
        let(:term_3) { RDF::Literal.new(20) }
        let(:the_array) do
          [{ sort: [term_2] },
           { sort: [term_3] },
           { sort: [term_1] }]
        end

        it "does numeric sort" do
          expected_results = [{ sort: [term_1] },
                              { sort: [term_2] },
                              { sort: [term_3] }]
          expect(subject).to eq expected_results
        end
      end

      context 'when sort values are string representations of integers' do
        let(:term_1) { RDF::Literal.new('1') }
        let(:term_2) { RDF::Literal.new('15') }
        let(:term_3) { RDF::Literal.new('20') }
        let(:the_array) do
          [{ sort: [term_2] },
           { sort: [term_3] },
           { sort: [term_1] }]
        end

        it "does numeric sort" do
          expected_results = [{ sort: [term_1] },
                              { sort: [term_2] },
                              { sort: [term_3] }]
          expect(subject).to eq expected_results
        end
      end

      context 'when sort values are a mix of integer representations' do
        let(:term_1) { RDF::Literal.new(1) }
        let(:term_2) { RDF::Literal.new('15') }
        let(:term_3) { RDF::Literal.new(20) }
        let(:term_4) { RDF::Literal.new('201') }
        let(:the_array) do
          [{ sort: [term_2] },
           { sort: [term_3] },
           { sort: [term_1] },
           { sort: [term_4] }]
        end

        it "does numeric sort" do
          expected_results = [{ sort: [term_1] },
                              { sort: [term_2] },
                              { sort: [term_3] },
                              { sort: [term_4] }]
          expect(subject).to eq expected_results
        end
      end
    end

    context 'as single value sort' do
      context 'when sort values do not have the language markers' do
        let(:term_1) { RDF::Literal.new("apple") }
        let(:term_2) { RDF::Literal.new("Banana") }
        let(:term_3) { RDF::Literal.new("carrot") }
        let(:the_array) do
          [{ sort: [term_2] },
           { sort: [term_3] },
           { sort: [term_1] }]
        end

        it 'does alpha sort ignoring case' do
          expected_results = [{ sort: [term_1] },
                              { sort: [term_2] },
                              { sort: [term_3] }]
          expect(subject).to eq expected_results
        end
      end

      context 'when sort values all have the same language marker' do
        let(:term_1) { RDF::Literal.new("apple", language: :en) }
        let(:term_2) { RDF::Literal.new("Banana", language: :en) }
        let(:term_3) { RDF::Literal.new("carrot", language: :en) }
        let(:the_array) do
          [{ sort: [term_2] },
           { sort: [term_3] },
           { sort: [term_1] }]
        end

        it 'does alpha sort ignoring case' do
          expected_results = [{ sort: [term_1] },
                              { sort: [term_2] },
                              { sort: [term_3] }]
          expect(subject).to eq expected_results
        end
      end

      context 'when sort values all have different language markers and no preferred language' do
        let(:term_1) { RDF::Literal.new("Kuh", language: :de) }
        let(:term_2) { RDF::Literal.new("Rind", language: :de) }
        let(:term_3) { RDF::Literal.new("bovine", language: :en) }
        let(:term_4) { RDF::Literal.new("cow", language: :en) }
        let(:term_5) { RDF::Literal.new("vache", language: :fr) }
        let(:term_6) { RDF::Literal.new("mucca") }
        let(:term_7) { RDF::Literal.new("vaca") }
        let(:the_array) do
          [{ sort: [term_5] },
           { sort: [term_7] },
           { sort: [term_2] },
           { sort: [term_6] },
           { sort: [term_1] },
           { sort: [term_4] },
           { sort: [term_3] }]
        end

        it 'does alpha sort of languages and alpha sort of terms within each language' do
          expected_results = [{ sort: [term_1] },
                              { sort: [term_2] },
                              { sort: [term_3] },
                              { sort: [term_4] },
                              { sort: [term_5] },
                              { sort: [term_6] },
                              { sort: [term_7] }]
          expect(subject).to eq expected_results
        end
      end

      context 'when sort values all have different language markers and has preferred language' do
        let(:preferred_language) { :en }

        let(:term_1) { RDF::Literal.new("bovine", language: :en) }
        let(:term_2) { RDF::Literal.new("cow", language: :en) }
        let(:term_3) { RDF::Literal.new("Kuh", language: :de) }
        let(:term_4) { RDF::Literal.new("Rind", language: :de) }
        let(:term_5) { RDF::Literal.new("vache", language: :fr) }
        let(:term_6) { RDF::Literal.new("mucca") }
        let(:term_7) { RDF::Literal.new("vaca") }
        let(:the_array) do
          [{ sort: [term_5] },
           { sort: [term_7] },
           { sort: [term_2] },
           { sort: [term_6] },
           { sort: [term_1] },
           { sort: [term_4] },
           { sort: [term_3] }]
        end

        it 'does alpha sort of languages shifting perferred language to the front and alpha sort of terms within each language' do
          expected_results = [{ sort: [term_1] },
                              { sort: [term_2] },
                              { sort: [term_3] },
                              { sort: [term_4] },
                              { sort: [term_5] },
                              { sort: [term_6] },
                              { sort: [term_7] }]
          expect(subject).to eq expected_results
        end
      end
    end

    context 'as multiple value sort' do
      context 'when all the terms in both lists have no language markers' do
        let(:term_1) { RDF::Literal.new("apple") }
        let(:term_2) { RDF::Literal.new("Banana") }
        let(:term_3) { RDF::Literal.new("carrot") }
        let(:term_4) { RDF::Literal.new("Woof Woof") }
        let(:the_array) do
          [{ sort: [term_2, term_1] },
           { sort: [term_3, term_2] },
           { sort: [term_1, term_3, term_4, term_2] }]
        end

        it 'does alpha sort ignoring case' do
          expected_results = [{ sort: [term_1, term_2] },
                              { sort: [term_1, term_2, term_3, term_4] },
                              { sort: [term_2, term_3] }]
          expect(subject).to eq expected_results
        end
      end

      context 'when all the terms in both lists have the same language markers' do
        let(:term_1) { RDF::Literal.new("bovine", language: :en) }
        let(:term_2) { RDF::Literal.new("Cow", language: :en) }
        let(:term_3) { RDF::Literal.new("hefer", language: :en) }
        let(:term_4) { RDF::Literal.new("Moo Moo", language: :en) }
        let(:the_array) do
          [{ sort: [term_2, term_1] },
           { sort: [term_3, term_2] },
           { sort: [term_1, term_3, term_4, term_2] }]
        end

        it 'does alpha sort ignoring case' do
          expected_results = [{ sort: [term_1, term_2] },
                              { sort: [term_1, term_2, term_3, term_4] },
                              { sort: [term_2, term_3] }]
          expect(subject).to eq expected_results
        end
      end

      context 'when terms exist in both lists that match the preferred language' do
        let(:preferred_language) { :en }

        let(:term_1) { RDF::Literal.new("bovine", language: :en) }
        let(:term_2) { RDF::Literal.new("cow", language: :en) }
        let(:term_3) { RDF::Literal.new("heffer", language: :en) }
        let(:term_4) { RDF::Literal.new("Kuh", language: :de) }
        let(:term_5) { RDF::Literal.new("Rind", language: :de) }
        let(:term_6) { RDF::Literal.new("vache", language: :fr) }
        let(:term_7) { RDF::Literal.new("mucca") }
        let(:term_8) { RDF::Literal.new("vaca") }
        let(:the_array) do
          [{ sort: [term_4, term_5, term_2, term_1] },
           { sort: [term_3, term_5, term_4, term_7, term_2] },
           { sort: [term_1, term_6, term_4, term_2, term_5, term_8, term_7, term_3] }]
        end

        it 'does alpha sort ignoring case on the preferred language only' do
          expected_results = [{ sort: [term_1, term_2, term_4, term_5] },
                              { sort: [term_1, term_2, term_3, term_4, term_5, term_6, term_7, term_8] },
                              { sort: [term_2, term_3, term_4, term_5, term_7] }]
          expect(subject).to eq expected_results
        end
      end

      context 'when there is complete chaos under heaven and all things are rotten' do
        let(:preferred_language) { :en }

        let(:term_1) { RDF::Literal.new("Kuh", language: :de) }
        let(:term_2) { RDF::Literal.new("Rind", language: :de) }
        let(:term_3) { RDF::Literal.new("hembra", language: :es) }
        let(:term_4) { RDF::Literal.new("res vacuna", language: :es) }
        let(:term_5) { RDF::Literal.new("vaca", language: :es) }
        let(:term_6) { RDF::Literal.new("vache", language: :fr) }
        let(:term_7) { RDF::Literal.new("ko") }
        let(:term_8) { RDF::Literal.new("mucca") }
        let(:the_array) do
          [{ sort: [term_4, term_5, term_2, term_1] }, # res vacuna, vaca, Rind, Kuh
           { sort: [term_3, term_5, term_4, term_7, term_2] }, # hembra, vaca, res vacuna, ko, Rind
           { sort: [term_3, term_6, term_5] }, # hembra, vache, vaca
           { sort: [term_1, term_6, term_4, term_2, term_5, term_8, term_7, term_3] }] # Kuh, vache, res vacuna, Rind, vaca, mucca, ko, hembra
        end

        it 'does alpha sort ignoring case on the preferred language only' do
          expected_results = [{ sort: [term_1, term_2, term_3, term_4, term_5, term_6, term_7, term_8] }, # Kuh, Rind, hembra, res vacuna, vaca, vache, ko, mucca
                              { sort: [term_2, term_3, term_4, term_5, term_7] }, # Kuh, Rind, res vacuna, vaca
                              { sort: [term_3, term_5, term_6] }, # hembra, vaca, vache
                              { sort: [term_1, term_2, term_4, term_5] }] # Rind, hembra, res vacuna, vaca, mucca
          expect(subject).to eq expected_results
        end
      end
    end
  end
end
