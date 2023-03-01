require 'rails_helper'

RSpec.describe SlackService do
    before(:each) do
        @channel_id = "C02HRH7MF5K"
        @timestamp = "1672861516089859"
  
        stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
        .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))
  
        stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=#{@channel_id}&timestamp=#{@timestamp}") \
        .to_return(body: File.read('spec/fixtures/slack/message_replies_response.json'))
  
        @test_module = create(:turing_module)
    end

  it 'can get channel members' do
    response = SlackService.get_channel_members(@channel_id)
    expect(response).to be_a(Hash)
    expect(response).to have_key(:data)
    expect(response[:data]).to be_a(Array)
    response[:data].each do |channel_member_data|
        expect(channel_member_data).to have_key(:id)
        expect(channel_member_data).to have_key(:type)
        expect(channel_member_data).to have_key(:attributes)
        expect(channel_member_data[:attributes]).to have_key(:slack_user_id)
        expect(channel_member_data[:attributes]).to have_key(:name)
    end 
  end

  it 'can get past meeting participant report' do
    response = SlackService.replies_from_message(@channel_id,@timestamp)
    expect(response).to be_a(Hash)
    expect(response).to have_key(:total_replies)
    expect(response).to have_key(:attendance_start_time)
    expect(response[:data]).to be_a(Array)
    response[:data].each do |student_reply|
        expect(student_reply).to have_key(:slack_id)
        expect(student_reply).to have_key(:status)
        expect(student_reply).to have_key(:reply_timestamp)
    end 
  end
end
