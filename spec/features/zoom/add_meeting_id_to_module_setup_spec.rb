require 'rails_helper'

RSpec.describe 'Add zoom meeting id during module setup' do 
    before(:each) do 
        @user = mock_login
    end 

    xit 'updates existing student with a slack id' do 
        test_module = create(:turing_module)
        zoom_meeting_id = "ABC123"
        visit turing_module_zoom_integration_path(test_module)

        expect(page).to have_content("Import Zoom Accounts From Zoom Meeting")
        
        fill_in :zoom_meeting_id, with: zoom_meeting_id

        click_button "Import Zoom Accounts From Meeting"

        expect(current_path).to eq(turing_module_account_match_path(test_module))
    end 
end 