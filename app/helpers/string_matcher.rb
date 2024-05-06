require 'fuzzystringmatch'

module StringMatcher
  def string_distance(s1, s2)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    jarow.getDistance(s1, s2)
  end

  def find_jarow_match(string, list)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure) # creates an instance of the Jaro-Winkler algorithm
    list.max_by do |list_item| # max_by finds the item in the list with the highest similarity to the string
      jarow.getDistance(string, list_item) # calculates the Jaro-Winkler distance between the input string and the current item in the list
    end # returns the item in the list with the highest similarity to the input string
  end
end