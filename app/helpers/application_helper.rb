module ApplicationHelper
  def find_jarow_match(student, student_list)
    match = student_list.max_by do |name, id|
      jarow = FuzzyStringMatch::JaroWinkler.create(:pure)
      jarow.getDistance(student.name, name)
    end
    return match[1]
  end
end
