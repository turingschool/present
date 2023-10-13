FactoryBot.define do
  factory :inning do
    sequence(:start_date) { |i| Date.today+(7.weeks*i) }
    name { '2107' }
    current { true }
    
    trait :not_current_past do
      current { false }
      start_date { Date.today-5.weeks }
    end

    trait :current_past do
      current { true }
      start_date { Date.today-5.weeks }
    end

    trait :is_current do
      current { true }
      start_date { Date.today+7.weeks }
    end

    trait :not_current_future do
      current { false }
      start_date { Date.today+15.weeks }
    end
  end
end
