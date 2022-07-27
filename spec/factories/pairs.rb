FactoryBot.define do
  factory :pair do
    name { Faker::Team.name }
    size { rand(2..5) }
  end
end
