require 'rails_helper'

RSpec.describe ZoomMeeting do
  describe 'relationships' do
    it {should have_many(:zoom_aliases).dependent(:destroy)}
    it {should have_one :attendance}
    it {should have_one(:turing_module).through(:attendance)}
  end

  describe "instance methods" do
    describe "#record_student_attendance_hours"
  end

  describe 'class methods' do
    describe '.from_meeting_details' do
      before :each do 
        @test_zoom_meeting_id = "95490216907"
        allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token
        stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
          .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))
      end

      it "creates the zoom meeting" do
        zoom = ZoomMeeting.from_meeting_details(@test_zoom_meeting_id)
        expect(zoom.meeting_id).to eq(@test_zoom_meeting_id)
        expect(zoom.start_time).to eq(DateTime.parse("Tue, 10 Jan 2023 15:45:22 UTC +00:00"))
        expect(zoom.end_time).to eq(DateTime.parse("Tue, 10 Jan 2023 17:00:22 UTC +00:00"))
        expect(zoom.title).to eq("ReadMe Workshop")
        expect(zoom.duration).to eq(75)
      end

      it "does not duplicate meeting records with the same meeting id" do
        ZoomMeeting.from_meeting_details(@test_zoom_meeting_id)
        ZoomMeeting.from_meeting_details(@test_zoom_meeting_id)
        expect(ZoomMeeting.count).to eq(1)
      end

      it 'will update existing records if any non unique fields changed' do
        zoom = ZoomMeeting.from_meeting_details(@test_zoom_meeting_id)
        zoom.update!(title: "Fake Title", start_time: Time.now, end_time: Time.now, duration: 0)

        zoom = ZoomMeeting.from_meeting_details(@test_zoom_meeting_id)
        expect(zoom.meeting_id).to eq(@test_zoom_meeting_id)
        expect(zoom.start_time).to eq(DateTime.parse("Tue, 10 Jan 2023 15:45:22 UTC +00:00"))
        expect(zoom.end_time).to eq(DateTime.parse("Tue, 10 Jan 2023 17:00:22 UTC +00:00"))
        expect(zoom.title).to eq("ReadMe Workshop")
        expect(zoom.duration).to eq(75)
        expect(ZoomMeeting.count).to eq(1)
      end      
    end
  end
end