FactoryBot.define do
  factory :attendance do
    sequence(:zoom_meeting_id) { |n| "<zoom_meeting_#{n}>" }
    turing_module
    user
    meeting_title { 'Test Title'}
    meeting_time { '2021-12-10 23:10:49 UTC' }
  end
end
