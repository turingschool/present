require 'rails_helper'

RSpec.describe "Dashboard" do
  before(:each) do
    @user = mock_login
    @my_mod = create(:turing_module)
  end

  it 'shows a welcome message' do
    visit '/'

    expect(page).to have_content("Welcome #{@user.email}!")
  end

  context 'if my_module is set' do
    before(:each) do
      @user.update(turing_module: @my_mod)
    end

    it 'user can see their module linked' do
      visit '/'

      expect(page).to have_content("Your Module: #{@my_mod.name}")
      expect(page).to have_link(@my_mod.name, href: turing_module_path(@my_mod))
    end
    
    it 'user cant take attendance for their mod if account match isnt complete' do
      visit '/'

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_content('Take Attendance for a Slack or Zoom Meeting')
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
    it 'User sees a message about getting started' do
      visit '/'
      expect(page).to have_content('Use the buttons below to set your Module. Then click the link to your Module to get started.')
    end
  end
end
