FactoryBot.define do
  factory :inning do
    name { '2107' }
    current { true }
    start_date {Date.today+2.weeks}
    
    trait :not_current_past do
      current { false }
      start_date {Date.today-5.weeks}
    end
    trait :is_current do
      current { true }
      start_date {Date.today-2.weeks}
    end
    trait :not_current_future do
      current { false }
      start_date {Date.today+2.weeks}
    end
  end
end
