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
          create(:student_attendance, attendance: attendance, student: create(:setup_student))
        end
      end
    end
  end
end
