FactoryBot.define do
    factory :slack_member do
      turing_module
      sequence(:slack_user_id) { |n| "<slack_user_#{n}>" }
      name { Faker::Name.name }
    end
  end
  