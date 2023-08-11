require 'rails_helper'

RSpec.describe "Nav Bar" do
  context 'user is not logged in' do
    it 'non registered user cant see link to see all innings' do
      visit root_path
      expect(page).to_not have_link("Log Out")
    end
  end

  it 'has a link to the root page' do
    visit root_path
    
    expect(page).to have_link("Present!", href: "/")
  end

  context 'user is logged in as default user_type' do
    it 'default user is not able to see admin button' do
      create(:inning)
      user = mock_login

      visit root_path
      expect(page).to_not have_button("Admin")
    end
  end

  context 'user is logged in as admin' do
    it 'admin user is able to see admin button' do
      create(:inning)
      user = mock_admin_login

      visit root_path
      expect(page).to have_button("Admin")
    end
  end
end
