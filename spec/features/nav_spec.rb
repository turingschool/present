require 'rails_helper'

RSpec.describe "Nav Bar" do
  it 'registered user can see link to see all innings' do
    user = mock_login

    visit root_path
    within('#nav') do
      click_link "All Innings"
    end
    expect(current_path).to eq(innings_path)
  end

  it 'non registered user cant see link to see all innings' do
    visit root_path
    expect(page).to_not have_link("All Innings")
  end

  it 'has a link to the dashboard' do
     mock_login

     visit root_path
     expect(page).to have_link('Dashboard', href: '/')
  end

  it 'has a link to the current inning' do
    mock_login
    current_inning = create(:inning, current: true)

    visit root_path
    expect(page).to have_link('Current Inning', href: inning_path(current_inning))
  end

  it 'does not have a link to the current inning when there is no current inning' do
    mock_login

    visit root_path
    expect(page).to_not have_link('Current Inning')
  end

end
