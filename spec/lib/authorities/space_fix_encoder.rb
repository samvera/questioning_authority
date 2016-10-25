require 'spec_helper'

describe Qa::Authorities::AssignFast::SpaceFixEncoder do
  let(:encoder) { described_class.new }

  it 'encodes spaces as %20 instead of +' do
    input = { "query" => "word ling", "queryIndex" => "suggestall", "queryReturn" => "suggestall,idroot,auth,type", "suggest" => "autoSubject", "rows" => "20" }
    expected = "query=word%20ling&queryIndex=suggestall&queryReturn=suggestall%2Cidroot%2Cauth%2Ctype&rows=20&suggest=autoSubject"
    expect(encoder.encode(input)).to eq expected
  end
end
