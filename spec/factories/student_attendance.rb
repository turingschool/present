FactoryBot.define do
  factory :student_attendance do
    student
    attendance

    factory :student_attendance_zoom do
      zoom_alias
    end

    factory :student_attendance_with_status do
      student {create(:setup_student)}

      factory :student_attendance_present do
        status { :present }
        join_time { Faker::Time.between(from: Time.now - 10.minutes, to: Time.now + 45.minutes) }
      end
      
      factory :student_attendance_tardy do
        status { :tardy }
        join_time { Faker::Time.between(from: Time.now - 10.minutes, to: Time.now + 45.minutes) }
      end

      factory :student_attendance_absent do
        status { :absent }
        join_time { nil }
      end
    end
  end
end
