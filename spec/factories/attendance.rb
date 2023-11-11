FactoryBot.define do
  factory :attendance do
    turing_module
    user
    attendance_time { Time.now }
    end_time { Time.now + 1.hour }
    meeting {create(:zoom_meeting)}

    factory :attendance_with_student_attendances do
      factory :zoom_attendance do
        meeting {create(:zoom_meeting_with_details)}

        after(:create) do |attendance|
          2.times do 
            create(:student_attendance_present, attendance: attendance)
          end
          2.times do 
            create(:student_attendance_tardy, attendance: attendance)
          end
          2.times do 
            create(:student_attendance_absent, attendance: attendance)
          end
        end
      end
    
      factory :slack_attendance do
        meeting {create(:slack_thread_with_details)}

        trait :presence_check_complete do
          meeting {create(:slack_thread_with_details, presence_check_complete: true)}
        end
        
        trait :presence_check_incomplete do
          meeting {create(:slack_thread_with_details, presence_check_complete: false)}
        end

        
        factory :slack_attendance_with_students do
          after(:create) do |attendance|
            2.times do 
              create(:student_attendance_present, attendance: attendance)
            end
            2.times do 
              create(:student_attendance_tardy, attendance: attendance)
            end
            2.times do 
              create(:student_attendance_absent, attendance: attendance)
            end
          end
        end
      end
    end
  end
end
