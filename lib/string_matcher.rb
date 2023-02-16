require 'fuzzystringmatch'

module StringMatcher
  def find_jarow_match(string, list)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    list.max_by do |list_item|
      jarow.getDistance(string, list_item)
    end
  end
end