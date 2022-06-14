FactoryBot.define do
  factory :attendance do
    sequence(:zoom_meeting_id) { |n| "<zoom_meeting_#{n}>" }
    turing_module
    user
    meeting_title { 'Test Title'}
    meeting_time { '2021-12-10 23:10:49 UTC' }

    factory :attendance_with_students do
      transient do
        num_students { 10 }
      end

      after(:create) do |attendance, evaluator|
        evaluator.num_students.times do
          student = create(:student, turing_module: attendance.turing_module)
          create(:student_attendance, student: student, attendance: attendance)
        end
      end
    end
  end
end
