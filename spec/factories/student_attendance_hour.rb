FactoryBot.define do
  factory :student_attendance_hour do
    student_attendance
    status { [:present, :absent].sample }
    start { Time.now - 2.hours}
    end_time { Time.now - 1.hours}
    duration { (0..60).to_a.sample}
  end
end