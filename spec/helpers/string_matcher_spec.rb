require 'rails_helper'

RSpec.describe StringMatcher do
  describe '#sanitize_name' do
    it 'returns the name downcased and no trailing white spaces' do
      expect(sanitize_name('Ed C FE   ')).to eq('ed c fe')
      expect(sanitize_name('Edward CHAMBERS')).to eq('edward chambers')
      expect(sanitize_name('Adam B (he/him), FE')).to eq('adam b (he/him), fe')
    end
  end

  describe '#string_distance' do
    # higher number --> more similar
    it 'returns the correct Jaro-Winkler distance between two strings' do
      expect(string_distance('Austin Carr-Jones', 'Austin Carr-Jones')).to eq(1.0)
      expect(string_distance('Austin Carr-Jones', 'Austin Kenny')).to be_within(0.835).of(0.836)
      expect(string_distance('Austin Carr-Jones', 'Austin c')).to be_within(0.86).of(0.861)
      expect(string_distance('Austin Carr-Jones', 'Austin k')).to be_within(0.86).of(0.861)
      expect(string_distance('Austin Carr-Jones', 'Austin')).to be_within(0.86).of(0.861)
      expect(string_distance('Austin Carr-Jones', '')).to eq(0.0)
      expect(string_distance('Austin Carr-Jones', '78$%()*')).to eq(0.0)
    end
  end
  
  describe '#name_distance' do
    # lower number --> more similar
    it 'returns the correct Levenshtein distance in similarity between two names' do
      expect(name_distance('Austin Carr-Jones', 'Austin Carr-Jones')).to eq(0)
      expect(name_distance('Austin Carr-Jones', 'Austin Kenny')).to eq(9)
      expect(name_distance('Austin Carr-Jones', 'Austin c')).to eq(9)
      expect(name_distance('Austin Carr-Jones', 'Austin k')).to eq(10)
      expect(name_distance('Austin Carr-Jones', 'Austin')).to eq(11)
      expect(name_distance('Austin Carr-Jones', '')).to eq(17)
      expect(name_distance('Austin Carr-Jones', '78$%()*')).to eq(17)
    end

    it 'is case insensitive' do
      expect(name_distance('john doe', 'john doe')).to eq(0)
      expect(name_distance('JoHn DoE', 'john doe')).to eq(0)
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
        expect(find_jarow_match('C', courses)).to eq('C#.NET Mod 0')
        expect(find_jarow_match('Mod 0', courses)).to eq('BE Mod 0 Classic')
        expect(find_jarow_match('3', courses)).to eq('BE Mod 3 Professional Rails Applications')
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
