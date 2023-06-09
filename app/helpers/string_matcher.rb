require 'fuzzystringmatch'

module StringMatcher
  def string_distance(s1, s2)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    jarow.getDistance(s1, s2)
  end

  def find_jarow_match(string, list)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    list.max_by do |list_item|
      jarow.getDistance(string, list_item)
    end
  end
end