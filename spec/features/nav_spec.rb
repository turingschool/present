require 'rails_helper'

RSpec.describe "Nav Bar" do
  context 'user is not logged in' do
    it 'non registered user cant see link to see all innings' do
      visit root_path
      expect(page).to_not have_link("All Modules")
    end
  end

  context 'user is logged in' do
    before(:each) do
      mock_login
      create(:inning)
    end

    it 'registered user can see link to see all innings' do
      visit root_path
      within('#nav') do
        expect(page).to have_link("All Modules")
      end
    end

    it 'has a link to the current inning' do
      visit root_path
      expect(page).to have_link("All Modules")
    end
  end
end
