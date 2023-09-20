FactoryBot.define do
  factory :zoom_alias do
    name {Faker::Name.name}
    zoom_meeting
    turing_module
    
    factory :alias_for_student do
      student
    end
  end
end
