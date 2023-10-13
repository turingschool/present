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
      @inning3 = create(:inning, :current_past, name: '2101')
      @inning2 = create(:inning, :not_current_future, name: '2201')
      @inning1 = create(:inning, current: false, name: '2205', start_date: Date.today+21.weeks)
      @inning4 = create(:inning, current: false, name: '2208', start_date: Date.today+28.weeks)

      @inning2.make_current_inning
      visit admin_path
    end

    it 'displays the current inning and all future innings in ascending order by start date' do
      within('.innings-list') do
        expect(page).to have_content("#{@inning1.name} - Start Date: #{@inning1.start_date.strftime('%d%b%Y')}")
        expect(page).to have_content("#{@inning2.name} - Start Date: #{@inning2.start_date.strftime('%d%b%Y')} (Current Inning)")
        expect(page).to have_content("#{@inning4.name} - Start Date: #{@inning4.start_date.strftime('%d%b%Y')}")
        expect(@inning2.name).to appear_before(@inning1.name)
        expect(@inning1.name).to appear_before(@inning4.name)
        expect(page).to_not have_content(@inning3.name)
        expect(page).to_not have_content(@inning3.start_date)
      end
    end

    it 'displays link to edit inning next to each inning' do
      within('.innings-list') do
        Inning.current_and_future.all.each do |inning|
          within("#inning-#{inning.id}") do
            expect(page).to have_link("Edit")
            expect("Edit").to appear_before(inning.name)
          end
        end
      end
    end

    it 'routes to inning edit page when you click link' do
      within('.innings-list') do
        within("#inning-#{@inning1.id}") do
          click_link "Edit"
          expect(current_path).to eq(edit_admin_inning_path(@inning1))         
        end
      end
    end

    it 'has a link to create a new inning' do
      expect(page).to have_link("Create New Inning")
      click_link "Create New Inning"
      expect(current_path).to eq(new_admin_inning_path)
    end
  end
end