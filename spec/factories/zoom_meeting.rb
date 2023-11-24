FactoryBot.define do
  factory :zoom_meeting do
    sequence(:meeting_id) { |n| n }

    factory :zoom_meeting_with_details do
      title { "ReadMe Workshop" }
      start_time { Time.parse("2023-01-10T15:45:22Z") }
    end
  end
end
  