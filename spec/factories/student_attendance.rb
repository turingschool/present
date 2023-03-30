FactoryBot.define do
  factory :student_attendance do
    student
    attendance
    factory :student_attendance_with_status do
      status { [:present, :absent, :tardy].sample }
      join_time { Faker::Time.between(from: DateTime.now - 60, to: DateTime.now + 60) }
    end
  end
end
