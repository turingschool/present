FactoryBot.define do
  factory :student do
    turing_module
    sequence(:zoom_id) { |n| "<zoom_id>_#{n}" }
    name { Faker::Name.name }
  end
end
