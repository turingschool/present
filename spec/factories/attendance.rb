FactoryBot.define do
  factory :attendance do
    turing_module
    user
    attendance_time { Time.now }
    meeting {create(:zoom_meeting)}
  end
end
