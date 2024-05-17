require 'fuzzystringmatch'
require 'text'

module StringMatcher
  def sanitize_name(name)
    name.downcase.strip
  end

  def string_distance(s1, s2)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    jarow.getDistance(s1, s2)
  end

  def name_distance(s_name, s_alias)
    Text::Levenshtein.distance(sanitize_name(s_name), sanitize_name(s_alias))
  end

  def find_jarow_match(string, list)
    jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
    list.max_by do |list_item|
      jarow.getDistance(string, list_item)
    end
  end
end
