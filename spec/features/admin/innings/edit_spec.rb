require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe 'Inning Edit' do
  # include ApplicationHelper
  before :each do
    mock_admin_login
    @inning1 = create(:inning, :current_past, name: '1000')
    @inning2 = create(:inning, :not_current_future, name: '1000')
    Sidekiq::Testing.disable!
    InningRolloverJob.perform_at(@inning2.start_date.to_time, @inning2.id)
    @jobs = Sidekiq::ScheduledSet.new
    visit edit_admin_inning_path(@inning2)
  end
  
  after :each do
    Sidekiq::ScheduledSet.new.clear
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

  describe 'Reschedule Job upon inning start date change' do
    it 'does not reschedule job if start date is not changed' do
      job = @jobs.find do |job|
        job.item["args"] == [@inning2.id] && job.display_class == "InningRolloverJob"
      end
      expect(@inning2.name).to eq('1000')
      expect(Time.at(job.score).strftime('%d%b%Y')).to eq(@inning2.start_date.strftime('%d%b%Y'))

      fill_in 'inning[name]', with: '2201'

      click_button 'Update Inning'
      @inning2.reload

      expect(@inning2.name).to eq('2201')
      expect(Time.at(job.score).strftime('%d%b%Y')).to eq(@inning2.start_date.strftime('%d%b%Y'))
    end

    it 'reschedules job if start date is changed' do
      job = @jobs.find do |job|
        job.item["args"] == [@inning2.id] && job.display_class == "InningRolloverJob"
      end
      expect(@inning2.name).to eq('1000')
      expect(Time.at(job.score).strftime('%d%b%Y')).to eq(@inning2.start_date.strftime('%d%b%Y'))

      fill_in 'inning[start_date]', with: Date.today + 14.weeks

      click_button 'Update Inning'
      @inning2.reload
      # test that old job does not exist
      new_job = @jobs.find do |job|
        job.item["args"] == [@inning2.id] && job.display_class == "InningRolloverJob"
      end
      expect(@inning2.name).to eq('1000')
      expect(Time.at(new_job.score).strftime('%d%b%Y')).to eq(@inning2.start_date.strftime('%d%b%Y'))
      expect(job.score).to_not eq(new_job.score)
    end
  end
end