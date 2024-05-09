require 'rails_helper'
require './spec/fixtures/populi/test_data/stub_requests.rb'

RSpec.describe CreateAttendanceFacade do
  describe 'class methods' do
    describe '.check_or_create_populi_course_meeting' do
      context 'zoom meeting' do
        it 'creates a new populi course meeting for zoom if there are no corresponding meetings by start_time' do
          facade = CreateAttendanceFacade
          test_zoom_meeting_id = 95490216907
          test_module = create(:setup_module)

          response = {
            "object": "course_attendance",
            "id": 179442,
            "student_id": 24490190,
            "course_meeting_id": 7134,
            "status": "excused",
            "present_coef": 1,
            "note": nil,
            "kiosk_id": nil,
            "beacon_id": nil,
            "device_id": nil,
            "beacon_found_at": nil,
            "attendance_hours": 2.5,
            "added_by_id": 24490729,
            "added_at": "2024-05-08T18:24:55+00:00",
            "clinical_hours": 2.5,
            "sandbox": true
          }
          
          stub_course_meetings
          stub_enrollments
          stub_create_student_attendance
          allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token

          meeting = stub_request(:get, "https://api.zoom.us/v2/meetings/#{test_zoom_meeting_id}") \
            .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

          meeting_details = JSON.parse(meeting.response.body, symbolize_names: true)
          meeting_details[:start_time] = "2024-05-08T15:00:00"

          expect(PopuliService.new.create_student_attendance(test_module.populi_course_id, "76297621", "2024-05-08T15:00:00")).to eq(response)

          result = facade.check_or_create_populi_course_meeting(meeting_details, test_module)
         
        end
        
        it 'creates a new populi course meeting for zoom if there are no meetings' do
          facade = CreateAttendanceFacade
          test_zoom_meeting_id = 95490216907
          test_module = create(:setup_module)
          course_offering_id = test_module.populi_course_id
        # We need a course_offering_id
          stub_course_meetings
          allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token

          meeting = stub_request(:get, "https://api.zoom.us/v2/meetings/#{test_zoom_meeting_id}") \
            .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

          meeting_details = JSON.parse(meeting.response.body, symbolize_names: true)

          facade.check_or_create_populi_course_meeting(meeting_details, test_module)
          expect(PopuliService.course_meetings(course_offering_id)).to eq(meeting_details)
          expect(PopuliService.course_meetings(course_offering_id).count).to eq(1)
          expe
        end

        it 'does not create a zoom meeting if one already exists' do
          # Need to create at least 2 other meetings. One with the same id
        end
      end
      
      context 'slack meeting' do
        it 'creates a new populi course meeting for slack if one does not exist' do
          @test_module = create(:setup_module)
          @channel_id = "C02HRH7MF5K"
          @timestamp = "1672861516089859"
          
          stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
          .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))
          stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=#{@channel_id}&timestamp=#{@timestamp}") \
          .to_return(body: File.read('spec/fixtures/slack/message_replies_response.json'))
        end

        it 'does not create a slack meeting if one already exists' do

        end
      end
    end
  end
end