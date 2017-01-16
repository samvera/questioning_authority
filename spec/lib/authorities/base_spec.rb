require 'spec_helper'

describe Qa::Authorities::Base do
  describe '#all' do
    it 'is unimplemeted' do
      expect { subject.all }.to raise_error NotImplementedError
    end
  end

  describe '#find' do
    it 'is unimplemeted' do
      expect { subject.find('moomin') }.to raise_error NotImplementedError
    end
  end
end
