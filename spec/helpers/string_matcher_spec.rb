require 'rails_helper'

RSpec.describe StringMatcher do
  describe '#sanitize_name' do
    it 'returns the first name and last initial of a name downcased' do
      expect(sanitize_name('Ed C FE')).to eq('ed c')
      expect(sanitize_name('Edward Chambers')).to eq('edward c')
      expect(sanitize_name('Adam B (he/him), FE')).to eq('adam b')
    end
    
    context 'when the name does not have a last name' do
      it 'returns the name downcased' do
        expect(sanitize_name('maTt')).to eq('matt')
      end
    end
  end

  describe '#string_distance' do
    it 'returns the correct Jaro-Winkler distance in similarity between two strings' do
      expect(string_distance('test', 'test')).to eq(1.0)
      expect(string_distance('test', 'tssts').round(2)).to eq(0.81)
      expect(string_distance('test', '907$#@.:!').round(2)).to eq(0.0) # special characters
      expect(string_distance('test', '').round(2)).to eq(0.0) # empty string
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
