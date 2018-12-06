require 'spec_helper'

RSpec.describe Qa::LinkedData::LanguageSortService do
  describe "#sort" do
    subject { described_class.new(terms, preferred_language).sort }

    let(:preferred_language) { nil }

    context 'when sort values all have the same language marker' do
      let(:term_1) { RDF::Literal.new("apple", language: :en) }
      let(:term_2) { RDF::Literal.new("Banana", language: :en) }
      let(:term_3) { RDF::Literal.new("carrot", language: :en) }
      let(:terms) { [term_2, term_3, term_1] }

      it "does alpha sort ignoring case" do
        expected_results = [term_1, term_2, term_3]
        expect(subject).to eq expected_results
      end
    end

    # Sort the literals within their languages. (e.g. 'Kuh':de, 'Rind':de, 'bovine':en, 'cow':en, 'vache':fr, 'vaca')
    context 'when sort values have the different language markers' do
      let(:term_1) { RDF::Literal.new("Kuh", language: :de) }
      let(:term_2) { RDF::Literal.new("Rind", language: :de) }
      let(:term_3) { RDF::Literal.new("bovine", language: :en) }
      let(:term_4) { RDF::Literal.new("cow", language: :en) }
      let(:term_5) { RDF::Literal.new("vache", language: :fr) }
      let(:term_6) { RDF::Literal.new("mucca") }
      let(:term_7) { RDF::Literal.new("vaca") }
      let(:terms) { [term_5, term_7, term_2, term_6, term_1, term_4, term_3] }

      it "does alpha sort ignoring case" do
        expected_results = [term_1, term_2, term_3, term_4, term_5, term_6, term_7]
        expect(subject).to eq expected_results
      end
    end

    # Sort the literals within their languages giving preference to one language. (e.g. 'bovine':en, 'cow':en, 'Kuh':de, 'Rind':de, 'vache':fr, 'vaca')
    context 'when some of the sort values have the preferred language' do
      let(:preferred_language) { :en }

      let(:term_1) { RDF::Literal.new("bovine", language: :en) }
      let(:term_2) { RDF::Literal.new("cow", language: :en) }
      let(:term_3) { RDF::Literal.new("heffer", language: :en) }
      let(:term_4) { RDF::Literal.new("Kuh", language: :de) }
      let(:term_5) { RDF::Literal.new("Rind", language: :de) }
      let(:term_6) { RDF::Literal.new("vache", language: :fr) }
      let(:term_7) { RDF::Literal.new("mucca") }
      let(:term_8) { RDF::Literal.new("vaca") }
      let(:terms) { [term_7, term_5, term_3, term_2, term_1, term_6, term_4, term_8] }

      it "does alpha sort ignoring case" do
        expected_results = [term_1, term_2, term_3, term_4, term_5, term_6, term_7, term_8]
        expect(subject).to eq expected_results
      end
    end
  end
end
