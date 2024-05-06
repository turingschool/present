require 'rails_helper'
require 'string_matcher'
require 'fuzzystringmatch'

RSpec.describe StringMatcher do
  include StringMatcher

  describe '#string_distance' do
    it 'returns the correct distance in similarity between two strings' do
      expect(string_distance('John', 'John')).to eq(1.0)
      expect(string_distance('John', 'Jon')).to be_within(0.01).of(0.94)
      expect(string_distance('John J', 'John Johnson')).to be_within(0.01).of(0.91)
      expect(string_distance('Jon', 'Johnathan')).to be_within(0.01).of(0.82)
      expect(string_distance('John', 'Jane')).to be_within(0.01).of(0.67)
    end
  end
end
