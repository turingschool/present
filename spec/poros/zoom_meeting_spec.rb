require 'rails_helper'

RSpec.describe ZoomMeeting do
  before(:each) do
    @test_meeting_id = '95490216907'

    @details_stub = stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_details.json'))

    @report_stub = stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_participant_report.json'))
  end

  it 'exists' do
    zoom_meeting = ZoomMeeting.new(@test_meeting_id)
    expect(zoom_meeting).to be_an_instance_of(ZoomMeeting)
  end

  it 'has the meeting details' do
    zoom_meeting = ZoomMeeting.new(@test_meeting_id)

    expect(zoom_meeting.id).to eq(@test_meeting_id)
    expect(zoom_meeting.title).to eq('Cohort Standup') #from spec/fixtures/zoom_meeting_details.json
    expect(zoom_meeting.start_time).to eq("2021-12-17T16:00:00Z") #from spec/fixtures/zoom_meeting_details.json
  end

  it 'has the meeting participant report' do
    zoom_meeting = ZoomMeeting.new(@test_meeting_id)
    expect(zoom_meeting.participants).to be_an(Array)
    expect(zoom_meeting.participants.first).to be_a(ZoomParticipant)
    expect(zoom_meeting.participants.first.name).to eq("Ryan Teske (He/Him)")
    expect(zoom_meeting.participants.first.id).to eq("E0WPTrXCQAGkMsvF9rQgQA")
  end

  it 'memoizes the api calls' do
    zoom_meeting = ZoomMeeting.new(@test_meeting_id)
    zoom_meeting.meeting_details
    zoom_meeting.participants
    zoom_meeting.meeting_details
    zoom_meeting.participants
    zoom_meeting.meeting_details
    zoom_meeting.participants
    expect(@details_stub).to have_been_requested.times(1)
    expect(@report_stub).to have_been_requested.times(1)
  end

  describe 'valid_id?' do
    it 'returns true if the meeting is found' do
      zoom_meeting = ZoomMeeting.new(@test_meeting_id)

      expect(zoom_meeting.valid_id?).to eq(true)
    end

    it 'returns false if the meeting id is invalid' do
      invalid_zoom_id = 'InvalidID'
      stub_request(:get, "https://api.zoom.us/v2/meetings/#{invalid_zoom_id}") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_details_invalid.json'))

      zoom_meeting = ZoomMeeting.new(invalid_zoom_id)

      expect(zoom_meeting.valid_id?).to eq(false)
    end
  end
end
