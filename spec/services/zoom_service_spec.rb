require 'rails_helper'

RSpec.describe ZoomService do
  it 'can get meeting details' do
    test_meeting_id = '95490216907'
    stub_request(:get, "https://api.zoom.us/v2/meetings/#{test_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_details.json'))

    response = ZoomService.meeting_details(test_meeting_id)
    expect(response).to be_a(Hash)
    expect(response).to have_key(:start_time)
    expect(response).to have_key(:id)
    expect(response).to have_key(:topic)
  end

  it 'can get past meeting participant report' do
    test_meeting_id = '95490216907'
    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{test_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_participant_report.json'))

    response = ZoomService.past_participants_meeting_report(test_meeting_id)
    expect(response[:page_size]).to eq(300)
    expect(response[:participants]).to be_an(Array)
    expect(response[:participants].first).to be_a(Hash)
    expect(response[:participants].first).to have_key(:user_id)
    expect(response[:participants].first).to have_key(:name)
    expect(response[:participants].first).to have_key(:user_email)
    expect(response[:participants].first).to have_key(:join_time)
  end

end
