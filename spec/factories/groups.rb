FactoryBot.define do
  factory :group do
    name { Faker::Team.name }
    project
  end
end
