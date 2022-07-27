FactoryBot.define do
  factory :project do
    name { Faker::Team.name }
    size { rand(2..5) }
  end
end
