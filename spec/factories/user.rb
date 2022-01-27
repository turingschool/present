FactoryBot.define do
  factory :user do
    google_id  { 123 }
    email { 'Alan.Turing@gmail.com' }
    google_oauth_token { '<google_oauth_token>' }
    google_refresh_token { '<google_refresh_token>' }
  end
end
