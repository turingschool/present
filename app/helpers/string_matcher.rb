require 'fuzzystringmatch'
require 'text'

module StringMatcher
  def sanitize_name(name)
    if name.include?(' ')
      first, last = name.downcase.strip.split(' ', 2).then { |first, last| "#{first} #{last[0]}" }
    else
      name = name.downcase.strip
    end
  end

  def string_distance(s1, s2)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    jarow.getDistance(s1.downcase, s2.downcase)
  end

  def name_distance(s_name, s_alias)
    Text::Levenshtein.distance(sanitize_name(s_name), sanitize_name(s_alias))
  end

  def find_jarow_match(string, list)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure) # creates an instance of the Jaro-Winkler algorithm
    list.max_by do |list_item| # max_by finds the item in the list with the highest similarity to the string
      jarow.getDistance(string.downcase, list_item.downcase) # calculates the Jaro-Winkler distance between the input string and the current item in the list
    end # returns the item in the list with the highest similarity to the input string
  end
end
