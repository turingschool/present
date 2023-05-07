FactoryBot.define do
  factory :attendance do
    turing_module
    user
    attendance_time { Time.now }
    meeting {create(:zoom_meeting)}

    factory :attendance_with_student_attendances do
      factory :zoom_attendance do
        meeting {create(:zoom_meeting_with_details)}

        after(:create) do |attendance|
          2.times do 
            create(:student_attendance_present, attendance: attendance, zoom_alias: create(:zoom_alias, zoom_meeting: attendance.meeting))
          end
          2.times do 
            create(:student_attendance_tardy, attendance: attendance, zoom_alias: create(:zoom_alias, zoom_meeting: attendance.meeting))
          end
          2.times do 
            create(:student_attendance_absent, attendance: attendance)
          end
        end
      end
    
      factory :slack_attendance do
        meeting {create(:slack_thread_with_details)}
        
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
