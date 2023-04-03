FactoryBot.define do
  factory :attendance do
    turing_module
    user
    attendance_time { Time.now }
    meeting {create(:zoom_meeting)}

    factory :zoom_attendance do
      meeting {create(:zoom_meeting_with_details)}
      after(:create) do |attendance|
        5.times do 
          create(:student_attendance_with_status, attendance: attendance, student: create(:setup_student))
        end
      end
    end
   
    factory :slack_attendance do
      meeting {create(:slack_thread_with_details)}
      after(:create) do |attendance|
        5.times do 
          create(:student_attendance_with_status, attendance: attendance, student: create(:setup_student))
        end
      end
    end
  end
end
