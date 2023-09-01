require 'rails_helper'

RSpec.describe 'Admin Dashboard' do
  # include ApplicationHelper
  before :each do
    mock_admin_login
    visit admin_path
  end

  describe 'Page Display' do
    it 'diplays "Admin Dashboard"' do
      expect(page).to have_content("Admin Dashboard")
      expect(page).to have_button("Admin")
    end

    it 'displays innings section if innings are present' do
      inning1 = create(:inning, :is_current)
      expect(page).to have_content("Innings")
    end
  end

  describe 'Within the Innings section' do
    before :each do
      @inning1 = create(:inning, :is_current)
      @inning2 = create(:inning, :not_current_future, name: '2201')
      @inning3 = create(:inning, :not_current_past, name: '2104')
      @inning4 = create(:inning, current: false, name: '2205', start_date: Date.today+3.weeks)
      visit admin_path
    end

    it 'displays the current inning and all future innings in ascending order by start date' do
      within('.innings-list') do
        expect(page).to have_content("#{@inning1.name} - Start Date: #{@inning1.start_date.strftime('%d%b%Y')} (Current Inning)")
        expect(page).to have_content("#{@inning2.name} - Start Date: #{@inning2.start_date.strftime('%d%b%Y')}")
        expect(page).to have_content("#{@inning4.name} - Start Date: #{@inning4.start_date.strftime('%d%b%Y')}")
        expect(@inning1.name).to appear_before(@inning2.name)
        expect(@inning2.name).to appear_before(@inning4.name)
        expect(page).to_not have_content(@inning3.name)
        expect(page).to_not have_content(@inning3.start_date)
      end
    end

    it 'displays link to edit inning next to each inning' do
      within('.innings-list') do
        4.times do
          expect(page).to have_link("Edit")
        end
        Innings.each do |inning|
          within(".#{inning.id}") do
            expect("Edit").to appear_before(inning.name)
          end
        end
      end
    end
  end
end