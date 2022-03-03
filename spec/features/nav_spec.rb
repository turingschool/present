require 'rails_helper'

RSpec.describe "Nav Bar" do
  it 'registered user can see link to see all innings' do
    user = mock_login

    visit dashboard_path

    click_link "All Innings"

    expect(current_path).to eq(innings_path)
  end
  it 'non registered user cant see link to see all innings' do
    visit root_path

    expect(page).to_not have_link("All Innings")
  end

end
