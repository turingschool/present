FactoryBot.define do
  factory :student do
    turing_module
    zoom_email { Faker::Internet.email }
    sequence(:zoom_id) { |n| "<zoom_id>_#{n}" }
    name { Faker::Name.name }
  end
end
