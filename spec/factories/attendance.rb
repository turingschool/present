FactoryBot.define do
  factory :attendance do
    turing_module
    user
    attendance_time { Time.now }
  end
end
