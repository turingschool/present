require 'rails_helper'

RSpec.describe 'Importing Slack Channel Members' do 
    before(:each) do 
        @user = mock_login
    end 
    context 'when a slack channel is given' do 
        it 'users can add a slack channel to a module' do 
            mod = create(:turing_module)
            slack_channel_id = "ABC123"
            visit turing_module_slack_integration_path(mod)

            fill_in :slack_channel_id, with: slack_channel_id
            click_button "Import Channel"

            mod.reload 

            expect(page).to have_content("Successfully uploaded Channel #{slack_channel_id}")
            expect(current_path).to eq(turing_module_zoom_integration_path(mod))
            expect(mod.slack_channel_id).to eq(slack_channel_id)
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

    context 'with an invalid slack channel id' do 
        before(:each) do
            @bad_channel_id = "NOTVALIDID"
      
            stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@bad_channel_id}") \
            .to_return(body: {}.to_json, status: 404) # Slack Service is not set to handle this edge case yet, it will return a 500.
      
            @test_module = create(:turing_module)
          end

          xit 'flashes a message to explain the issue' do 
            visit turing_module_slack_channel_import_path(@test_module)

            fill_in :slack_channel_id, with: @bad_channel_id 
            click_button "Import Members From Channel"
            
            expect(current_path).to eq(turing_module_slack_channel_import_path(@test_module))
            expect(page).to have_content("Please provide a valid channel id.")
          end 
    end 

end 