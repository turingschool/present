require 'rails_helper'
require './spec/fixtures/populi/test_data/stub_requests.rb'

RSpec.describe CreateAttendanceFacade do
  describe 'class methods' do
    describe '.check_or_create_populi_course_meeting' do
      context 'zoom meeting' do
        before :each do
          allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token
          @facade = CreateAttendanceFacade
          @test_zoom_meeting_id = 95490216907
          @test_module = create(:setup_module)
          @test_module.populi_course_id = "10548007"
          @zoom_url = "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}"
          stub_enrollments
        end

        it 'creates a new populi course meeting for zoom if there are no corresponding meetings by start_time' do
          stub_request(:get, @zoom_url).to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))
          stub_create_student_attendance
          stub_course_meetings

          created_meeting = @facade.create_meeting(@zoom_url)
          created_meeting.start_time = "2024-05-13T15:30:00.000+00:00".to_datetime
          
          result = @facade.check_or_create_populi_course_meeting(created_meeting, @test_module)

          expect(result).to be_a(Hash)
          expect(result).to have_key(:object)
          expect(result[:object]).to eq("course_attendance")
          expect(result).to have_key(:id)
          expect(result[:id]).to be_a(Integer)
          expect(result).to have_key(:student_id)
          expect(result[:student_id]).to be_a(Integer)
          expect(result).to have_key(:course_meeting_id)
          expect(result[:course_meeting_id]).to be_a(Integer)
          expect(result).to have_key(:status)
          expect(result[:status]).to eq("excused")
          expect(result).to have_key(:attendance_hours)
          expect(result[:attendance_hours]).to be_a(Float)
          expect(result).to have_key(:clinical_hours)
          expect(result[:clinical_hours]).to be_a(Float)
        end
        
        it 'creates a new populi course meeting for zoom if there are no meetings' do
          stub_request(:get, @zoom_url).to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))
          stub_no_course_meetings
          stub_create_student_attendance
          
          created_meeting = @facade.create_meeting(@zoom_url)
          created_meeting.start_time = "2024-05-13T15:30:00.000+00:00".to_datetime
          
          result = @facade.check_or_create_populi_course_meeting(created_meeting, @test_module)
          
          expect(result).to be_a(Hash)
          expect(result).to have_key(:object)
          expect(result[:object]).to eq("course_attendance")
          expect(result).to have_key(:id)
          expect(result[:id]).to be_a(Integer)
          expect(result).to have_key(:student_id)
          expect(result[:student_id]).to be_a(Integer)
          expect(result).to have_key(:course_meeting_id)
          expect(result[:course_meeting_id]).to be_a(Integer)
          expect(result).to have_key(:status)
          expect(result[:status]).to eq("excused")
          expect(result).to have_key(:attendance_hours)
          expect(result[:attendance_hours]).to be_a(Float)
          expect(result).to have_key(:clinical_hours)
          expect(result[:clinical_hours]).to be_a(Float)
        end

        it 'does not create a zoom meeting if one already exists with a corresponding start_time' do
          stub_request(:get, @zoom_url).to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))
          stub_course_meetings
          
          created_meeting = @facade.create_meeting(@zoom_url)
          created_meeting.start_time = "2022-11-28T09:00:00-07:00".to_datetime
          
          result = @facade.check_or_create_populi_course_meeting(created_meeting, @test_module)
          
          expect(result).to eq("Meeting already exists in Populi.")
        end
      end
      
      context 'slack meeting' do
        before :each do
          @facade = CreateAttendanceFacade
          @test_module = create(:setup_module)
          @channel_id = "C02HRH7MF5K"
          @timestamp = "1672861516089859"
          @slack_url = "https://turingschool.slack.com/archives/#{@channel_id}/#{@timestamp}"
          stub_enrollments
        end

        it 'creates a new populi course meeting for slack if no meetings exist' do
          stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
          .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))
          
          stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=C02HRH7MF5K&timestamp=672861516089859").
          with(
            headers: {
           'Accept'=>'*/*',
           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
           'User-Agent'=>'Faraday v1.10.3'
            }).
          to_return(status: 200, body: File.read('spec/fixtures/slack/message_replies_response.json', headers: {}))
          
          stub_no_course_meetings
          stub_create_student_attendance
          
          created_meeting = @facade.create_meeting(@slack_url)
          created_meeting.start_time = "2022-11-28T09:00:00-07:00".to_datetime
          
          result = @facade.check_or_create_populi_course_meeting(created_meeting, @test_module)
       
          expect(result).to be_a(Hash)
          expect(result).to have_key(:object)
          expect(result[:object]).to eq("course_attendance")
          expect(result).to have_key(:id)
          expect(result[:id]).to be_a(Integer)
          expect(result).to have_key(:student_id)
          expect(result[:student_id]).to be_a(Integer)
          expect(result).to have_key(:course_meeting_id)
          expect(result[:course_meeting_id]).to be_a(Integer)
          expect(result).to have_key(:status)
          expect(result[:status]).to eq("excused")
          expect(result).to have_key(:attendance_hours)
          expect(result[:attendance_hours]).to be_a(Float)
          expect(result).to have_key(:clinical_hours)
          expect(result[:clinical_hours]).to be_a(Float)
        end

        it 'creates a new populi course meeting for slack if there are no corresponding meetings by start_time' do
          stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
          .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))
          
          stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=C02HRH7MF5K&timestamp=672861516089859").
          with(
            headers: {
           'Accept'=>'*/*',
           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
           'User-Agent'=>'Faraday v1.10.3'
            }).
          to_return(status: 200, body: File.read('spec/fixtures/slack/message_replies_response.json', headers: {}))

          stub_course_meetings
          stub_create_student_attendance
          
          created_meeting = @facade.create_meeting(@slack_url)
          created_meeting.start_time = "2023-01-21T09:00:00-07:00".to_datetime
          
          result = @facade.check_or_create_populi_course_meeting(created_meeting, @test_module)
          
          expect(result).to be_a(Hash)
          expect(result).to have_key(:object)
          expect(result[:object]).to eq("course_attendance")
          expect(result).to have_key(:id)
          expect(result[:id]).to be_a(Integer)
          expect(result).to have_key(:student_id)
          expect(result[:student_id]).to be_a(Integer)
          expect(result).to have_key(:course_meeting_id)
          expect(result[:course_meeting_id]).to be_a(Integer)
          expect(result).to have_key(:status)
          expect(result[:status]).to eq("excused")
          expect(result).to have_key(:attendance_hours)
          expect(result[:attendance_hours]).to be_a(Float)
          expect(result).to have_key(:clinical_hours)
          expect(result[:clinical_hours]).to be_a(Float)
        end

        it 'does not create new populi course meeting for slack if one already exists with a corresponding start_time' do
          stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
          .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))
                    
          stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=C02HRH7MF5K&timestamp=672861516089859").
          with(
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Faraday v1.10.3'
            }).
          to_return(status: 200, body: File.read('spec/fixtures/slack/message_replies_response.json', headers: {}))
    
          stub_course_meetings
          
          created_meeting = @facade.create_meeting(@slack_url)
          created_meeting.start_time = "2022-11-28T09:00:00-07:00".to_datetime
          
          result = @facade.check_or_create_populi_course_meeting(created_meeting, @test_module)
          
          expect(result).to eq("Meeting already exists in Populi.")
        end
      end
    end
  end
end