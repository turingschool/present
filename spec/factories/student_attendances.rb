FactoryBot.define do
  factory :student_attendance do
    status { 1 }
    student { nil }
    attendance { nil }
    join_time { "2022-02-16 09:43:43" }
  end
end
