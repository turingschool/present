require 'fuzzystringmatch'

module StringMatcher
  def sanitize_name(name)
    if name.include?(' ')
      first, last = name.downcase.strip.split(' ', 2).then { |first, last| "#{first} #{last[0]}" }
    else
      name = name.downcase.strip
    end
  end

  def string_distance(s1, s2) # higher number --> more similar
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    jarow.getDistance(s1.downcase, s2.downcase)
  end

  def find_jarow_match(string, list)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure) # creates an instance of the Jaro-Winkler algorithm
    list.max_by do |list_item| # max_by finds the item in the list with the highest similarity to the string
      jarow.getDistance(string.downcase, list_item.downcase) # calculates the Jaro-Winkler distance between the input string and the current item in the list
    end # returns the item in the list with the highest similarity to the input string
  end

  def find_best_match(s1, s2)
    first_s1, last_s1 = s1.split(' ', 2)
    first_s2, last_s2 = handle.split(' ', 2)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    first_name_distance = jarow.getDistance(first_s1.downcase, first_s2.downcase)
    last_name_distance = jarow.getDistance(last_s1[0].downcase, last_s2[0].downcase)
    (first_name_distance + last_name_distance) / 2.0
  end
end
