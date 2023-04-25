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
end
