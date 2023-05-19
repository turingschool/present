FactoryBot.define do
  factory :slack_presence_check do
    student {create :setup_student}
    check_time {Time.now}
    presence {[:active, :away].sample}
  end
end