FactoryBot.define do
  factory :student_attendance do
    status { [:present, :absent, :tardy].sample }
    student
    attendance
    join_time { Faker::Time.between(from: DateTime.now - 60, to: DateTime.now + 60) }
  end
end
