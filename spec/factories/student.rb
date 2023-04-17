FactoryBot.define do
  factory :student do
    name { Faker::Name.name }
    sequence(:slack_id) {|n| "<slack_id_#{n}>"}
    
    factory :setup_student do
      turing_module
      sequence(:populi_id) {|n| "<populi_id_#{n}>"}

      after :create do |student|
        create(:zoom_alias, student: student, name: Faker.name)
      end
    end
  end
end
