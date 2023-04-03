FactoryBot.define do
  factory :attendance do
    turing_module
    user
    attendance_time { Time.now }
    meeting {create(:zoom_meeting)}

    factory :attendance_with_student_attendances do
      after(:create) do |attendance|
        5.times do 
          create(:student_attendance_with_status, attendance: attendance, student: create(:setup_student))
        end
        create(:student_attendance, attendance: attendance, student: create(:setup_student), status: :absent, join_time: nil)
      end

      factory :zoom_attendance do
        meeting {create(:zoom_meeting_with_details)}
      end
    
      factory :slack_attendance do
        meeting {create(:slack_thread_with_details)}
      end
    end
  end
end
