require 'rails_helper'

RSpec.describe 'Importing Slack Channel Members' do 
    before(:each) do 
        @user = mock_login
    end 

    it 'module show page links to slack channel import page' do 
        mod = create(:turing_module)

        visit turing_module_path(mod)

        expect(page).to have_link("Import Slack Accounts", href: turing_module_slack_channel_import_path(mod))

        click_link "Import Slack Accounts"

        expect(page).to have_content("Import Members From Slack Channel")
    end 

    context 'with a valid slack channel id' do 
        before(:each) do
            @channel_id = "C02HRH7MF5K"
      
            stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
            .to_return(body: File.read('spec/fixtures/slack_channel_members_report.json'))
      
            @test_module = create(:turing_module)
          end

        it 'creates slack members for that turing module' do 
            visit turing_module_slack_channel_import_path(@test_module)

            fill_in :slack_channel_id, with: @channel_id 
            click_button "Import Members From Channel"
            
            expect(current_path).to eq(turing_module_path(@test_module))
            expect(page).to have_content("53 members from Cohort have been imported")
        end 
    end 

    context 'with an invalid slack channel id' do 
        before(:each) do
            @bad_channel_id = "NOTVALIDID"
      
            stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@bad_channel_id}") \
            .to_return(body: {}.to_json, status: 404) # Slack Service is not set to handle this edge case yet, it will return a 500.
      
            @test_module = create(:turing_module)
          end

          it 'flashes a message to explain the issue' do 
            visit turing_module_slack_channel_import_path(@test_module)

            fill_in :slack_channel_id, with: @bad_channel_id 
            click_button "Import Members From Channel"
            
            expect(current_path).to eq(turing_module_slack_channel_import_path(@test_module))
            expect(page).to have_content("Please provide a valid channel id.")
          end 
    end 

end 