require 'rails_helper'
require 'sidekiq/testing' 
require './spec/fixtures/populi/stub_requests.rb'

RSpec.describe 'Populi Transfer' do 
  include ApplicationHelper

  before :each do
    @user = mock_login
    @mod = create(:setup_module)

    @test_zoom_meeting_id = 96428502996

    allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token

    stub_get_enrollments

    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@mod.populi_course_id}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings_without_ids.xml'))
    
    visit turing_module_path(@mod)

    fill_in :attendance_meeting_url, with:  "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
                
    click_button 'Take Attendance'

    @test_attendance = Attendance.last

    Sidekiq::Testing.inline!
  end

  context "user follows instructions to create populi attendance record" do
    before :each do
      # Assume that the User has followed instructions to create attendance record in Populi. 
      # The corresponding meeting should be returned from the Populi API with a meetingID.
  
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@mod.populi_course_id}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))  
    end

    context "update successful" do
      it 'sends the request to update the students attendance in Populi' do
        stub_successful_update_student_attendance

        click_link "Transfer Student Attendances to Populi"

        expect(current_path).to eq("/attendances/#{@test_attendance.id}/populi_transfer/new")

        expect(page).to have_content(@test_attendance.meeting.title)
        expect(page).to have_content(pretty_time(@test_attendance.attendance_time))
        expect(page).to have_content(pretty_date(@test_attendance.attendance_time))
        expect(page).to have_content("Tardy: 2")
        expect(page).to have_content("Present: 2")
        expect(page).to have_content("Absent: 2")
        
        click_link "I have created the Attendance record in Populi"

        expect(page).to have_select(selected: "9:00 AM")

        click_button "Transfer Student Attendances to Populi"

        expect(current_path).to eq(attendance_path(@test_attendance))

        expect(page).to have_content("Transferring attendance to Populi")

        expect(@update_attendance_stub1).to have_been_requested
        expect(@update_attendance_stub2).to have_been_requested
        expect(@update_attendance_stub3).to have_been_requested
        expect(@update_attendance_stub4).to have_been_requested
        expect(@update_attendance_stub5).to have_been_requested
        expect(@update_attendance_stub6).to have_been_requested
      end    

      it 'can transfer to a different time slot' do
        update_response = File.read('spec/fixtures/populi/update_student_attendance_success.xml')

        @update_attendance_stub1 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1963", "personID"=>"24490140", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        @update_attendance_stub2 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1963", "personID"=>"24490130", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        # Absent
        @update_attendance_stub3 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1963", "personID"=>"24490100", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        # Absent due to tardiness
        @update_attendance_stub4 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1963", "personID"=>"24490062", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        @update_attendance_stub5 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1963", "personID"=>"24490161", "status"=>"TARDY", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        @update_attendance_stub6 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1963", "personID"=>"24490123", "status"=>"TARDY", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 

        click_link "Transfer Student Attendances to Populi"
        click_link "I have created the Attendance record in Populi"

        expect(page).to have_select(:populi_meeting_id)

        select("1:00 PM")
        click_button "Transfer Student Attendances to Populi"

        expect(@update_attendance_stub1).to have_been_requested
        expect(@update_attendance_stub2).to have_been_requested
        expect(@update_attendance_stub3).to have_been_requested
        expect(@update_attendance_stub4).to have_been_requested
        expect(@update_attendance_stub5).to have_been_requested
        expect(@update_attendance_stub6).to have_been_requested
      end
    end

    context "update error" do
      before :each do
        update_response = File.read('spec/fixtures/populi/update_student_attendance_success.xml')

        @update_attendance_stub1 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490140", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        @update_attendance_stub2 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490130", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        @update_attendance_stub3 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490100", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        
        # This attendance update fails for some reason
        @update_attendance_stub4 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490062", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_error.xml')) 
        
        @update_attendance_stub5 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490161", "status"=>"TARDY", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        @update_attendance_stub6 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490123", "status"=>"TARDY", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response)         

        click_link "Transfer Student Attendances to Populi"
        click_link "I have created the Attendance record in Populi"

        select("9:00 AM")
      end

      it 'keeps processing the job if it encounters an error' do
        click_button "Transfer Student Attendances to Populi"  

        expect(@update_attendance_stub1).to have_been_requested
        expect(@update_attendance_stub2).to have_been_requested
        expect(@update_attendance_stub3).to have_been_requested
        expect(@update_attendance_stub4).to have_been_requested # This call errors out, but the job should continue to requests 5 and 6
        expect(@update_attendance_stub5).to have_been_requested
        expect(@update_attendance_stub6).to have_been_requested
      end

      it 'sends a Honeybadger notification' do
        expect(Honeybadger).to receive(:notify).with("UPDATE FAILED. Student: 24490062, status: absent, response: {\"response\"=>{\"error\"=>\"Something went wrong\"}}")
        click_button "Transfer Student Attendances to Populi"  
      end

      it 'can handle a no method error' do
        # responding with an empty body so that it creates a no method error when accessing the response
        @update_attendance_stub4 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490062", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: "")

        expect(Honeybadger).to receive(:notify).with("UPDATE FAILED. Student: 24490062, status: absent, response: {}")
        
        click_button "Transfer Student Attendances to Populi"  
      end
      
      it 'can handle a populi error when the student is not found' do
        # responding with an error that says the student was not found
        @update_attendance_stub4 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490062", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_not_found.xml'))

        expect(Honeybadger).to receive(:notify).with("UPDATE FAILED. Student: 24490062, status: absent, response: {\"error\"=>{\"code\"=>\"BAD_PARAMETER\", \"message\"=>\"We could not find personID \\\"24490062\\\" in instanceID \\\"10547831\\\"\"}}")
        
        click_button "Transfer Student Attendances to Populi"  
      end
    end    
  end

  context "user doesn't follow instructions" do # Populi meeting won't have an id
    before :each do
      stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@mod.populi_course_id}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings_without_ids.xml'))  
    end
    
    it 'returns them to the populi transfer start page and displays an error' do
      click_link "Transfer Student Attendances to Populi"

      # Assume that the User has NOT followed instructions to create attendance record in Populi. 
      # The corresponding meeting should be returned from the Populi API WITHOUT a meetingID.
      click_link "I have created the Attendance record in Populi"

      select("9:00 AM")

      click_button "Transfer Student Attendances to Populi"

      expect(current_path).to eq(new_attendance_populi_transfer_path(@test_attendance))
      expect(page).to have_content("It looks like that Attendance hasn't been created in Populi yet. Please make sure you are following the directions below to create the Attendance record in Populi before proceeding")
    end
  end
end