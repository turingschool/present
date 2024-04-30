require 'rails_helper'
require './spec/fixtures/populi/test_data/stub_requests.rb'

RSpec.describe "Populi API is non-responsive" do
  before(:each) do
    #setup module as if API was responsive
    @user = mock_login
    @mod = create(:turing_module, module_number: 2, program: :BE)
    @facade = PopuliFacade.new(@mod)
    @channel_id = "C02HRH7MF5K"
    stub_persons
    stub_enrollments
    stub_academic_terms
    stub_current_academic_term
    stub_course_offerings_by_term
    stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
      .to_return(body: File.read('spec/fixtures/slack/channel_members_for_module_setup.json'))

    visit turing_module_populi_integration_path(@mod)

    within '#best-match' do
      click_button 'Yes'
    end

    fill_in :slack_channel_id, with: @channel_id
        click_button "Import Channel"

    click_button "Connect Accounts"
  end
  
  describe 'attempt to navigate to populi integration page with unresponsive API' do
    it 'redirects to modules show page' do
      allow_any_instance_of(PopuliService).to receive(:current_academic_term).and_return(nil)
      visit turing_module_populi_integration_path(@mod)
  
      expect(current_path).to eq(turing_module_path(@mod))
    end
  
    it 'flash error is shown when populi is non-responsive' do
      allow_any_instance_of(PopuliService).to receive(:current_academic_term).and_return(nil)
      visit turing_module_populi_integration_path(@mod)
      
      expect(page).to have_content("The page you are trying to access is currently unavailable. This may be due to an API call failing. Please try again later.")
    end
  end

  describe 'attempt to take attendance with unresponsive API' do
    it "slack attendance attempt" do
      allow_any_instance_of(PopuliService).to receive(:course_meetings).and_return(nil)

      @channel_id = "C02HRH7MF5K"
      @timestamp = "1672861516089859"

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
      .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=#{@channel_id}&timestamp=#{@timestamp}") \
      .to_return(body: File.read('spec/fixtures/slack/message_replies_response.json'))

      slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

      fill_in :attendance_meeting_url, with: slack_url
      click_button 'Take Attendance'

      expect(current_path).to eq(turing_module_path(@mod))
      expect(page).to have_content("The page you are trying to access is currently unavailable. This may be due to an API call failing. Please try again later.")
    end

    it "zoom attendance attempt" do
      allow_any_instance_of(PopuliService).to receive(:course_meetings).and_return(nil)

      @test_zoom_meeting_id = 95490216907

      allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
      click_button 'Take Attendance'

      expect(current_path).to eq(turing_module_path(@mod))
      expect(page).to have_content("The page you are trying to access is currently unavailable. This may be due to an API call failing. Please try again later.")
    end
  end
end