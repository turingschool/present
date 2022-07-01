require 'rails_helper'

RSpec.describe "Nav Bar" do
  context 'user is not logged in' do
    it 'non registered user cant see link to see all innings' do
      visit root_path
      expect(page).to_not have_link("All Innings")
    end

    it 'has a link to help' do
      visit root_path
      expect(page).to have_link('Help', href: '/help')
    end
  end

  context 'user is logged in' do
    before(:each) do
      mock_login
    end

    it 'registered user can see link to see all innings' do
      visit root_path
      within('#nav') do
        click_link "All Innings"
      end
      expect(current_path).to eq(innings_path)
    end



    it 'has a link to the dashboard' do
       visit root_path
       expect(page).to have_link('Dashboard', href: '/')
    end

    it 'has a link to the current inning' do
      current_inning = create(:inning, current: true)

      visit root_path
      expect(page).to have_link('Current Inning', href: inning_path(current_inning))
    end

    it 'does not have a link to the current inning when there is no current inning' do
      visit root_path
      expect(page).to_not have_link('Current Inning')
    end

    it 'has a link to help' do
      visit root_path
      expect(page).to have_link('Help', href: '/help')
    end
  end
end
