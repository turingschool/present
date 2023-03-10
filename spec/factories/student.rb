FactoryBot.define do
  factory :student do
    name { Faker.name }
    factory :setup_student do
      turing_module
      sequence(:slack_id) {|n| "<slack_id_#{n}"}
      sequence(:populi_id) {|n| "<populi_id_#{n}"}
      name { Faker::Name.name }

      after :create do |student|
        create(:zoom_alias, student: student, name: Faker.name)
      end
    end
  end
end