require 'rails_helper'

RSpec.describe 'Admin Dashboard' do
  # include ApplicationHelper
  before :each do
    mock_admin_login
  end

  describe 'Page Display' do
    it 'diplays "Admin Dashboard"' do
      visit admin_path
      
      expect(page).to have_content("Admin Dashboard")
      expect(page).to have_button("Admin")
    end
  end
end