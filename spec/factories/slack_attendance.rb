FactoryBot.define do
    factory :slack_attendance do
        attendance
        sequence(:channel_id) { |n| "<slack_channel_#{n}>" }
        sent_timestamp { Time.new('2021-12-10 23:10:49 UTC').to_datetime }
        attendance_start_time { Time.new('2021-12-10 23:10:49 UTC').to_datetime }
    end
  end
  