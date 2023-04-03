FactoryBot.define do
  factory :slack_thread do
    factory :slack_thread_with_details do
      channel_id {"C02HRH7MF5K"}
      sent_timestamp {"1672861516089859"}
      start_time { Time.parse("2022-11-30T20:00:59.999+00:00")}
    end
  end
end