FactoryBot.define do
  factory :student do
    name { Faker::Name.name }
    turing_module

    factory :setup_student do
      sequence(:slack_id) {|n| "<slack_id_#{n}>"}  
      sequence(:populi_id) {|n| "<populi_id_#{n}>"}
      
      after :create do |student|
        create(:zoom_alias, student: student, turing_module: student.turing_module)
      end
    end
  end
end
