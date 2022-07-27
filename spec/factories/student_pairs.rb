FactoryBot.define do
  factory :student_pair do
    name { "Group #{rand(1..8)}" }
    student
    project
  end
end
