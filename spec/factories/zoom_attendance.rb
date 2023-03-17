FactoryBot.define do
  factory :zoom_attendance do
    attendance
    zoom_meeting_id { Faker::Internet.uuid }
    meeting_title { 'Test Title'}
    meeting_time { '2021-12-10 23:10:49 UTC' }

    factory :zoom_attendance_with_students do
      transient do
        num_students { 10 }
      end

      after(:create) do |zoom_attendance, evaluator|
        evaluator.num_students.times do
          student = create(:student, turing_module: zoom_attendance.attendance.turing_module)
          create(:student_attendance, student: student, attendance: zoom_attendance.attendance)
        end
      end
    end

    factory :zoom_attendance_for_module do
      transient do
        statuses {[:present, :tardy, :absent]}
      end
      transient do
        turing_module
      end
      after(:create) do |zoom_attendance, evaluator|
        evaluator.turing_module.students.each.with_index do |student, index|
          status = evaluator.statuses[index]
          zoom_attendance.attendance.student_attendances.create!(student: student, status: status)
        end
      end
    end
  end
end
  