FactoryBot.define do
  factory :slack_thread do
    sequence(:channel_id) {|n| n}
    sequence(:sent_timestamp) {|n| n}
    factory :slack_thread_with_details do
      start_time { Time.parse("2022-11-30T20:00:59.999+00:00")}
      presence_check_complete { false }
    end
  end
end