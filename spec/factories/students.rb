FactoryBot.define do
  factory :student do
    turing_module
    sequence(:zoom_id) { |n| "<zoom_id>_#{n}" }
    name { Faker::Name.name }

    factory :student_with_slack_id do
      sequence(:slack_id) {|n| "<slack_id_#{n}"}
    end
  end
end
