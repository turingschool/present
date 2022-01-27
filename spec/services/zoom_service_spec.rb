require 'rails_helper'

RSpec.describe ZoomService do
  it 'can get meeting details' do
    response = ZoomService.meeting_details('95490216907')
    expect(response).to be_a(Hash)
    expect(response).to have_key(:start_time)
    expect(response).to have_key(:id)
    expect(response).to have_key(:topic)
  end

  it 'can get past meeting participant report' do
    response = ZoomService.past_participants_meeting_report('95490216907')
    expect(response[:page_size]).to eq(300)
    expect(response[:participants]).to be_an(Array)
    expect(response[:participants].first).to be_a(Hash)
    expect(response[:participants].first).to have_key(:user_id)
    expect(response[:participants].first).to have_key(:name)
    expect(response[:participants].first).to have_key(:user_email)
    expect(response[:participants].first).to have_key(:join_time)
  end

end
