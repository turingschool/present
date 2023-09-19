require 'rails_helper'

RSpec.describe 'Create New Inning' do
  before :each do
    mock_admin_login
    visit new_admin_inning_path
  end

  describe 'Create Form' do
    it 'has a form to create a new inning' do
      expect(page).to have_content('Create New Inning')
      expect(page).to have_field('inning[name]')
      expect(page).to have_field('inning[start_date]')
      expect(page).to have_button('Create Inning')
    end

    it 'creates a new inning when submitted' do
      fill_in 'inning[name]', with: '2401'
      fill_in 'inning[start_date]', with: Date.today + 3.weeks

      click_button 'Create Inning'

      expect(current_path).to eq(admin_path)
      expect(page).to have_content('2401')
      expect(page).to have_content('Start Date: ' + (Date.today + 3.weeks).strftime('%d%b%Y'))
    end

    it 'does not create if name is blank' do
      fill_in 'inning[name]', with: ''

      click_button 'Create Inning'

      expect(page).to have_content('Create New Inning')
      expect(page).to have_content("Name can't be blank")
      expect(current_path).to eq(admin_innings_path)
    end

    it 'does not create if start date is blank' do
      fill_in 'inning[name]', with: '2401'
      fill_in 'inning[start_date]', with: ''

      click_button 'Create Inning'

      expect(page).to have_content('Create New Inning')
      expect(page).to have_content("Start date can't be blank")
      expect(current_path).to eq(admin_innings_path)
    end
  end
end