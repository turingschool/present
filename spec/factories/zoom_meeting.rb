FactoryBot.define do
  factory :zoom_meeting do
    factory :zoom_meeting_with_details do
      meeting_id { "96428502996" }
      title { "ReadMe Workshop" }
      start_time { Time.parse("2023-01-10T15:45:22Z") }
    end
  end
end
  