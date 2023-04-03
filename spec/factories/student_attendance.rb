FactoryBot.define do
  factory :student_attendance do
    student
    attendance
    factory :student_attendance_with_status do
      status { [:present, :absent, :tardy].sample }
      join_time { Faker::Time.between(from: Time.now - 10.minutes, to: Time.now + 45.minutes) }
    end
  end
end
