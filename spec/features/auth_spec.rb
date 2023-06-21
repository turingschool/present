require 'rails_helper'

RSpec.describe "Authentication" do
  let(:google_id){'123'}
  let(:email){"john@example.com"}
  let(:google_oauth_token){'<OAUTH_TOKEN>'}
  let(:google_refresh_token){'<REFRESH_TOKEN>'}
  let(:organization_domain){'turing.edu'}

  before :each do
    create(:inning)

    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      "provider" => "google_oauth2",
      "uid" => google_id,
      "info" => {
        "name" => "John Smith",
        "email" => email,
        "first_name" => "John",
        "last_name" => "Smith"
      },
      "credentials" => {
        "token" => google_oauth_token,
        "refresh_token" => google_refresh_token,
        "expires_at" => 1496120719,
        "expires" => true
      },
      "extra" => {
        "raw_info" => {
          "hd" => organization_domain
        }
      }
    })

    OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }
  end

  it 'user can log in with google oauth' do
    visit '/'

    click_link 'Sign In With Google'

    expect(page).to have_link('Log Out')
    expect(page).to_not have_link('Sign In With Google')
  end

  it 'user can log out' do
    visit '/'

    click_link 'Sign In With Google'
    click_link('Log Out')
    expect(page).to have_link('Sign In With Google')
  end

  it 'creates a new user if they do not already exist' do
    visit '/'

    click_link 'Sign In With Google'

    user = User.last
    expect(user.email).to eq(email)
    expect(user.google_oauth_token).to eq(google_oauth_token)
    expect(user.google_refresh_token).to eq(google_refresh_token)
    expect(user.organization_domain).to eq(organization_domain)
    expect(User.count).to eq(1)
  end

  it 'does not create a new user if they already exist' do
    visit '/'
    
    User.create(google_id: google_id, email: email, google_oauth_token: google_oauth_token, google_refresh_token: google_refresh_token, organization_domain: organization_domain)
    click_link 'Sign In With Google'
    expect(User.count).to eq(1)
  end

  it 'shows a welcome message' do
    visit '/'

    click_link 'Sign In With Google'

    expect(page).to have_content("Welcome, #{email}!")
  end

  it 'displays a message for auth failure' do
    OmniAuth.config.mock_auth[:google_oauth2] = :csrf_detected

    visit '/'

    click_link 'Sign In With Google'

    expect(current_path).to eq(root_path)
    expect(page).to have_content("We had some trouble logging you in with Google. Please make sure you are signing in with a turing.edu account. If you continue to have issues, please contact the app maintainers.")
  end
end
