require 'rails_helper'
require './spec/fixtures/populi/stub_requests.rb'

RSpec.describe "Module Setup Slack Workflow" do
  before(:each) do
    @user = mock_login
    @mod = create(:turing_module, module_number: 2, program: :BE)
    @channel_id = "C02HRH7MF5K"
    stub_persons
    stub_course_offerings
    stub_current_academic_term
    stub_course_offerings_by_term

    stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
      .to_return(body: File.read('spec/fixtures/slack/channel_members_for_module_setup.json'))  
  end

  context 'user imports Populi students' do
    before :each do
      visit turing_module_populi_integration_path(@mod)

      within '#best-match' do
        click_button 'Yes'
      end
    end

    context 'when a slack channel isnt given' do 
      it 'user is redirected and told to provide a channel id' do 
        mod = create(:turing_module)

        visit turing_module_slack_integration_path(mod)

        fill_in :slack_channel_id, with: ""
        click_button "Import Channel"

        expect(page).to have_content("Please provide a Channel ID")
        expect(page).to have_content("Import Slack Channel")
      end 
    end  

    context 'when a valid slack channel id is given' do 
      before(:each) do
        visit turing_module_slack_integration_path(@mod)

        fill_in :slack_channel_id, with: @channel_id
        click_button "Import Channel"
      end

      it 'adds a slack channel to a module' do 
        @mod.reload 

        expect(@mod.slack_channel_id).to eq(@channel_id)
      end 

      it 'redirects to the zoom/new page' do
        expect(current_path).to eq(new_turing_module_account_match_path(@mod))
      end
    end
  end
end