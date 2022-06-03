require 'rails_helper'

RSpec.describe "Logging In" do
  it 'user can log in with google oauth' do
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      "provider" => "google_oauth2",
      "uid" => "153",
      "info" => {
        "name" => "John Smith",
        "email" => "john@example.com",
        "first_name" => "John",
        "last_name" => "Smith"
      },
      "credentials" => {
        "token" => "TOKEN",
        "refresh_token" => "REFRESH_TOKEN",
        "expires_at" => 1496120719,
        "expires" => true
      },
      "extra" => {
        "raw_info" => {
          "hd" => "turing.edu"
        }
      }
    })

    visit '/'

    click_link 'Sign In With Google'

    expect(current_path).to eq('/dashboard')
    expect(page).to have_link('Log Out')
  end

  it 'if user exists'
  it 'if user does not exist'
end
