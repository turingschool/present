require 'rails_helper'

RSpec.describe StringMatcher do
  describe '#string_distance' do
    it 'returns the correct distance in similarity between two strings' do
      expect(string_distance('John', 'John')).to eq(1.0)
      expect(string_distance('John', 'Jon')).to be_within(0.01).of(0.94)
      expect(string_distance('John J', 'John Johnson')).to be_within(0.01).of(0.91)
      expect(string_distance('John', 'Jane')).to be_within(0.01).of(0.67)
    end

    it 'returns the correct distance in similarity regardless of case' do
      expect(string_distance('john', 'John')).to eq(1.0)
      expect(string_distance('JOHN', 'jon')).to be_within(0.01).of(0.94)
      expect(string_distance('joHn j', 'John Johnson')).to be_within(0.01).of(0.91)
    end
  end

  describe '#name_distance' do
    it 'returns the correct distance in similarity between two names' do
      
    end
  end

  describe '#find_jarow_match' do
    # used in PopuliFacade to match the turing module name to the course abbrv from Populi API
    let(:courses) { [
      'BE Mod 0 Classic',
      'BE Mod 0 Intensive',
      'BE Mod 1 Object Oriented Programming with Ruby',
      'Be Mod 2 Web Application Development',
      'BE Mod 3 Professional Rails Applications',
      'BE Mod 4 Cross-Team Processes and Applications',
      'C#.NET Mod 0',
      'FE Mod 0 Intensive',
      'FE Mod 0 Classic',
      'FE Mod 1 Fundamental Web Technologies',
      'FE Mod 2 Web Development with JavaScript',
      'FE Mod 3 Professional Client Side Development',
      'FE Mod 4 Cross-Team Processes and Applications'
    ] }

    context 'when the string is exactly one of the list items' do
      it 'returns the exact match' do
        expect(find_jarow_match('BE Mod 0 Classic', courses)).to eq('BE Mod 0 Classic')
        expect(find_jarow_match('FE Mod 0 Intensive', courses)).to eq('FE Mod 0 Intensive')
      end
    end

    context 'when the string is similar to one of the list items' do
    it 'returns the item in the list with the highest similarity to the input string' do
        expect(find_jarow_match('C.', courses)).to eq('C#.NET Mod 0')
        expect(find_jarow_match('Mod 0', courses)).to eq('BE Mod 0 Classic')
        expect(find_jarow_match('FE Mod', courses)).to eq('FE Mod 0 Classic')
      end
    end
    
    context 'when the string is not similar to any of the list items' do
      it 'returns the item in the list with the highest similarity to the input string' do
        expect(find_jarow_match('xyz', courses)).to eq('BE Mod 0 Classic')
        expect(find_jarow_match('$*5', courses)).to eq('BE Mod 0 Classic')
      end
    end
  end
end
