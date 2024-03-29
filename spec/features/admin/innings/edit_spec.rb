require 'rails_helper'

RSpec.describe 'Inning Edit' do
  # include ApplicationHelper
  before :each do
    mock_admin_login
    @inning1 = create(:inning, :current_past, name: '1000')
    @inning2 = create(:inning, :not_current_future, name: '1000')

    visit edit_admin_inning_path(@inning2)
  end

  describe 'Update Form' do
    it 'has a pre-filled form to update the inning' do
      expect(page).to have_content('Edit Inning')
      expect(page).to have_field('inning[name]', with: @inning2.name)
      expect(page).to have_field('inning[start_date]', with: @inning2.start_date)
      expect(page).to have_button('Update Inning')
    end

    it 'updates date or name when submitted' do 
      fill_in 'inning[name]', with: '2201'
      fill_in 'inning[start_date]', with: Date.today + 14.weeks

      click_button 'Update Inning'

      edited_inning = Inning.find(@inning2.id)
      expect(current_path).to eq(admin_path)
      expect(edited_inning.name).to_not eq(@inning2.name)
      expect(edited_inning.start_date).to_not eq(@inning2.start_date)
      expect(page).to have_content('2201')
      expect(page).to have_content('Start Date: ' + (Date.today + 14.weeks).strftime('%d%b%Y'))
    end

    it 'does not update if name is blank' do
      fill_in 'inning[name]', with: ''

      click_button 'Update Inning'

      expect(page).to have_content('Edit Inning')
      expect(page).to have_content("Name can't be blank")
      expect(current_path).to eq(admin_inning_path(@inning2))
    end

    it 'does not update if start date is blank' do
      fill_in 'inning[start_date]', with: ''

      click_button 'Update Inning'
      expect(page).to have_content('Edit Inning')
      expect(page).to have_content("Start date can't be blank")
      expect(current_path).to eq(admin_inning_path(@inning2))
    end
  end
end