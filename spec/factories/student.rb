FactoryBot.define do
  factory :student do
    name { Faker::Name.name }
    turing_module

    factory :setup_student do
      sequence(:slack_id) {|n| "<slack_id_#{n}>"}  
      sequence(:populi_id) {|n| "<populi_id_#{n}>"}
      
      after :create do |student|
        create(:zoom_alias, student: student, turing_module: student.turing_module)
      end

      trait :with_attendances do 
        after :create do |student|
          zoom1, zoom2 = create_list(:zoom_attendance, 2, turing_module: student.turing_module)
          slack1, slack2 = create_list(:slack_attendance, 2, turing_module: student.turing_module)
          sa1 = create(:student_attendance, student: student, attendance: zoom1, status: :present)
          sa2 = create(:student_attendance, student: student, attendance: slack1, status: :tardy)
          sa3 = create(:student_attendance, student: student, attendance: zoom2, status: :absent)
          sa4 = create(:student_attendance, student: student, attendance: slack2, status: :present)
          create(:student_attendance_hour, student_attendance: sa1, status: :present, start: Time.parse("2023-11-06 09:00:00 -0700"), end_time: Time.parse("2023-11-06 10:00:00 -0700"), duration: 60)
          create(:student_attendance_hour, student_attendance: sa1, status: :present, start: Time.parse("2023-11-06 10:00:00 -0700"), end_time: Time.parse("2023-11-06 11:00:00 -0700"), duration: 60)
          create(:student_attendance_hour, student_attendance: sa1, status: :present, start: Time.parse("2023-11-06 11:00:00 -0700"), end_time: Time.parse("2023-11-06 12:00:00 -0700"), duration: 55)
          create(:student_attendance_hour, student_attendance: sa1, status: :present, start: Time.parse("2023-11-06 12:00:00 -0700"), end_time: Time.parse("2023-11-06 12:30:00 -0700"), duration: 30)

          create(:student_attendance_hour, student_attendance: sa2, status: :present, start: Time.parse("2023-11-06 13:00:00 -0700"), end_time: Time.parse("2023-11-06 14:00:00 -0700"), duration: 58)
          create(:student_attendance_hour, student_attendance: sa2, status: :absent, start: Time.parse("2023-11-06 14:00:00 -0700"), end_time: Time.parse("2023-11-06 15:00:00 -0700"), duration: 13)
          create(:student_attendance_hour, student_attendance: sa2, status: :absent, start: Time.parse("2023-11-06 15:00:00 -0700"), end_time: Time.parse("2023-11-06 16:00:00 -0700"), duration: 0)

          create(:student_attendance_hour, student_attendance: sa3, status: :absent, start: Time.parse("2023-11-07 09:00:00 -0700"), end_time: Time.parse("2023-11-07 10:00:00 -0700"), duration: 0)
          create(:student_attendance_hour, student_attendance: sa3, status: :absent, start: Time.parse("2023-11-07 10:00:00 -0700"), end_time: Time.parse("2023-11-07 11:00:00 -0700"), duration: 15)
          create(:student_attendance_hour, student_attendance: sa3, status: :absent, start: Time.parse("2023-11-07 11:00:00 -0700"), end_time: Time.parse("2023-11-07 12:00:00 -0700"), duration: 15)

          create(:student_attendance_hour, student_attendance: sa4, status: :present, start: Time.parse("2023-11-07 13:00:00 -0700"), end_time: Time.parse("2023-11-07 14:00:00 -0700"), duration: 60)
          create(:student_attendance_hour, student_attendance: sa4, status: :present, start: Time.parse("2023-11-07 14:00:00 -0700"), end_time: Time.parse("2023-11-07 15:00:00 -0700"), duration: 60)
          create(:student_attendance_hour, student_attendance: sa4, status: :present, start: Time.parse("2023-11-07 15:00:00 -0700"), end_time: Time.parse("2023-11-07 16:00:00 -0700"), duration: 60)
        end
      end
    end
  end
end
