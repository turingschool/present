require 'rails_helper'

RSpec.describe StringMatcher do
  describe '#string_distance' do
    it 'returns the correct distance in similarity between two strings' do
      expect(string_distance('John', 'John')).to eq(1.0)
      expect(string_distance('John', 'Jon')).to be_within(0.01).of(0.94)
      expect(string_distance('John J', 'John Johnson')).to be_within(0.01).of(0.91)
      expect(string_distance('Jon', 'Johnathan')).to be_within(0.01).of(0.82)
      expect(string_distance('John', 'Jane')).to be_within(0.01).of(0.67)
    end
  end

  describe '#find_jarow_match' do
    it 'returns the item in the list with the highest similarity to the input string' do
      list = ['John', 'Jon', 'John Johnson', 'Johnathan', 'Jane']
      expect(find_jarow_match('Johnny', list)).to eq('John')
      expect(find_jarow_match('John John', list)).to eq('John Johnson')
      expect(find_jarow_match('Jack', list)).to eq('Jane')
      expect(find_jarow_match('Bobby', list)).to eq('Jon')
    end
  end
end
