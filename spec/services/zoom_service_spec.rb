require 'rails_helper'

RSpec.describe ZoomService do
  describe "Authorization", cache: true do
    before :each do
      @test_meeting_id = '95490216907'
      @test_token = "test token"
      @request_token_stub = stub_request(:post, "https://zoom.us/oauth/token") \
                              .to_return(body: {access_token: @test_token}.to_json)

      @meeting_details_stub = stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_meeting_id}") \
                                  .with(headers: {Authorization: "Bearer #{@test_token}"}) \
                                  .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))                         
    end

    context "token is not expired" do
      it 'requests an oauth token when not stored in cache' do
        expect(Rails.cache.fetch("zoom_oauth_token")).to be_nil
        
        ZoomService.meeting_details(@test_meeting_id)

        expect(Rails.cache.fetch("zoom_oauth_token")).to eq(@test_token)
        expect(@request_token_stub).to have_been_requested.times(1)
        expect(@meeting_details_stub).to have_been_requested.times(1)
      end

      it 'uses the oauth token when stored in cache' do
        Rails.cache.fetch("zoom_oauth_token") { @test_token } # write the oauth token to cache
        ZoomService.meeting_details(@test_meeting_id)
        expect(@request_token_stub).to_not have_been_requested
        expect(@meeting_details_stub).to have_been_requested.times(1)
      end
    end

    context "token is expired unexpectedly" do
      before :each do
        @expired_token = "expired token"
        @expired_stub = stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_meeting_id}") \
                          .with(headers: {Authorization: "Bearer #{@expired_token}"}) \
                          .to_return(body: File.read('spec/fixtures/zoom/auth_token_expired.json'))                         

        Rails.cache.fetch("zoom_oauth_token") { @expired_token } # Write the expired token to cache
      end

      it 'replaces the expired token with the new token in the cache' do
        expect(Rails.cache.fetch("zoom_oauth_token")).to eq(@expired_token)        
        ZoomService.meeting_details(@test_meeting_id)
        expect(Rails.cache.fetch("zoom_oauth_token")).to eq(@test_token)        
      end

      it 'requests the new oauth token' do
        ZoomService.meeting_details(@test_meeting_id)
        expect(@request_token_stub).to have_been_requested.times(1)
      end

      it 'retries the request and sends back a valid response' do
        response = ZoomService.meeting_details(@test_meeting_id)
        expect(@expired_stub).to have_been_requested.times(1)
        expect(@meeting_details_stub).to have_been_requested.times(1)
        expect(response).to have_key(:start_time)
      end
    end
  end

  describe 'api calls' do
    before(:each) do
      @test_meeting_id = '95490216907'

      allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))
    end

    it 'can get meeting details' do
      response = ZoomService.meeting_details(@test_meeting_id)
      expect(response).to be_a(Hash)
      expect(response).to have_key(:start_time)
      expect(response).to have_key(:id)
      expect(response).to have_key(:topic)
    end

    it 'can get past meeting participant report' do
      response = ZoomService.participant_report(@test_meeting_id)
      expect(response[:page_size]).to eq(300)
      expect(response[:participants]).to be_an(Array)
      expect(response[:participants].first).to be_a(Hash)
      expect(response[:participants].first).to have_key(:user_id)
      expect(response[:participants].first).to have_key(:name)
      expect(response[:participants].first).to have_key(:user_email)
      expect(response[:participants].first).to have_key(:join_time)
    end
  end
end
