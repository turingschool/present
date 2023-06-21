require 'rails_helper'

RSpec.describe "Dashboard" do
  before(:each) do
    @user = mock_login
    @my_mod = create(:turing_module)
  end

  context 'if my_module is set' do
    before(:each) do
      @user.update(turing_module: @my_mod)
    end

    it 'redirects them to their mod show page' do
      visit '/'

      expect(current_path).to eq(turing_module_path(@my_mod))
    end

    it 'user can navigate to other modules', js: true do
      other_mod = create(:setup_module, inning: @my_mod.inning)

      visit '/'

      within '#turing-module-selection' do
        select other_mod.name
      end

      expect(current_path).to eq(turing_module_path(other_mod))
    end
    
    context 'if account match is complete' do
      before(:each) do
        @my_mod = create(:setup_module)
        @user.update(turing_module: @my_mod)
      end

      it 'user can take attendance for their mod if account match is complete' do
        create_list(:student, 10, turing_module: @my_mod)
        @my_mod.reload

        visit '/'

        expect(page).to_not have_link("Setup Module")
        expect(page).to have_content('Take Attendance for a Slack or Zoom Meeting')
        expect(page.find('form#take-attendance')['method']).to eq('post')
        expect(page.find('form#take-attendance')['action']).to eq(turing_module_attendances_path(@my_mod))
        expect(page.find('form#take-attendance')['method']).to eq('post')
        expect(page.find('form#take-attendance')['action']).to eq(turing_module_attendances_path(@my_mod))
      end
    end
  end
    

  context 'if my_module is not set' do
    it 'User sees all modules' do
      create_list(:turing_module, 3, inning: @my_mod.inning)
      visit '/'
      expect(page).to have_content('Select your Module from the list to get started')
      expect(page).to have_css(".module", count: 4)
    end
  end
end
