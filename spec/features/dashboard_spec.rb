require 'rails_helper'

RSpec.describe "Dashboard" do
  before(:each) do
    @user = mock_login
  end

  it 'shows a welcome message' do
    visit '/'

    expect(page).to have_content("Welcome #{@user.email}!")
  end

  context 'if my_module is set' do
    before(:each) do
      @my_mod = create(:turing_module)
      @user.update(turing_module: @my_mod)
    end

    it 'user can see their module linked' do
      visit '/'

      expect(page).to have_content("My Module: #{@my_mod.name}")
      expect(page).to have_link(@my_mod.name, href: turing_module_path(@my_mod))
    end

    it 'user can take attendance for their mod' do
      visit '/'

      expect(page).to have_content('Take Attendance for my mod:')
      expect(page.find('form#take-attendance')['method']).to eq('post')
      expect(page.find('form#take-attendance')['action']).to eq(turing_module_attendances_path(@my_mod))
    end

    it 'does not show current inning info' do
      current_inning = create(:inning, current: true)

      visit '/'

      expect(page).to_not have_content("Current Inning:")
    end
  end

  context 'if my_module is not set and there is a current inning' do
    before(:each) do
      @current_inning = create(:inning, current: true)
      @current_modules = create_list(:turing_module, 3, inning: @current_inning)
    end

    it 'User sees a message about my_module' do
      visit '/'
      expect(page).to have_content("My Module is not set. To set My Module visit a module page.")
    end

    it 'shows the current inning and its modules' do
      visit '/'

      expect(page).to have_content("Current Inning: #{@current_inning.name}")
      @current_modules.each do |mod|
        expect(page).to have_link(mod.name, href: turing_module_path(mod))
      end
    end
  end

  context 'if my_module is not set and there is no current inning' do
    it 'shows a message about customizing the dashboard' do
      visit '/'

      expect(page).to have_content('No Inning is set as the current inning. Visit the All Innings page to set the current inning.')
      within '#main-content' do
        expect(page).to have_link('All Innings', href: innings_path)
      end
    end
  end


end
