FactoryBot.define do
  factory :user do
    google_id  { 123 }
    email { 'Alan.Turing@gmail.com' }
    google_oauth_token { '<google_oauth_token>' }
    google_refresh_token { '<google_refresh_token>' }
    factory :admin do
      user_type {:admin}
      organization_domain {'turing.edu'}
    end
  end
end
