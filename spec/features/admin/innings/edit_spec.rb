require 'rails_helper'

RSpec.describe 'Inning Edit' do
  # include ApplicationHelper
  before :each do
    mock_admin_login
    @inning1 = create(:inning, :is_current)
    @inning2 = create(:inning, :not_current_future, name: '2201')
    
    visit edit_admin_inning_path(@inning1)
  end

  describe 'Update Form' do
    it 'has a pre-filled form to update the inning' do
      save_and_open_page

      expect(page).to have_content('Edit Inning Form')
      expect(page).to have_field('inning[name]', with: @inning1.name)
      expect(page).to have_field('inning[start_date]', with: @inning1.start_date)
      expect(page).to have_button('Update Inning')
    end
  end
end