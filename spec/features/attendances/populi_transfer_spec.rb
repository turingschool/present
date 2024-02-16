require 'rails_helper'
require 'sidekiq/testing' 
require './spec/fixtures/populi/test_data/stub_requests.rb'

RSpec.describe 'Populi Transfer' do 
  include ApplicationHelper

  before :each do
    @user = mock_login
    @mod = create(:setup_module)

    @test_zoom_meeting_id = 96428502996

    allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token

    stub_get_enrollments # Need enrollment ids to update student attendance in Populi
    # see stub_requests.rb for the stubs/ more info 

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
        stub_successful_update_student_attendance
        
        click_link "Transfer Student Attendances to Populi"
        click_link "I have created the Attendance record in Populi"

        expect(page).to have_select(:populi_meeting_id)

        select("1:00 PM")
        click_button "Transfer Student Attendances to Populi"

        expect(@update_attendance_stub7).to have_been_requested
        expect(@update_attendance_stub8).to have_been_requested
        expect(@update_attendance_stub9).to have_been_requested
        expect(@update_attendance_stub10).to have_been_requested
        expect(@update_attendance_stub11).to have_been_requested
        expect(@update_attendance_stub12).to have_been_requested
      end
    end

    context "update error" do
      before :each do      
        course_offering_id = "10547831"
        enrollment_id_1 = "76297621"
        enrollment_id_2 = "76296027"
        enrollment_id_3 = "76296028"
        enrollment_id_4 = "76296029"
        enrollment_id_5 = "76296030"
        enrollment_id_6 = "76296031"
        status_present = "present"
        status_absent = "absent"
        status_tardy = "tardy"
        course_meeting_id_1 = "1962"

      @update_attendance_stub1 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_1}/attendance/update").
        with(
          body: {course_meeting_id: course_meeting_id_1, status: status_present},
          headers: {
        'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
          }).
        to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_1.json'))
      
      @update_attendance_stub2 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_2}/attendance/update").
        with(
          body: {course_meeting_id: course_meeting_id_1, status: status_present},
          headers: {
        'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
          }).
        to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_2.json'))
      
      @update_attendance_stub3 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_3}/attendance/update").
        with(
          body: {course_meeting_id: course_meeting_id_1, status: status_absent},
          headers: {
        'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
          }).
        to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_3.json'))
      
      @update_attendance_stub4 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_4}/attendance/update").
        with(
          body: {course_meeting_id: course_meeting_id_1, status: status_absent},
          headers: {
        'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
          }).
        to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/error/update_student_attendance_no_course_meeting.json'))
      
      @update_attendance_stub5 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_5}/attendance/update").
        with(
          body: {course_meeting_id: course_meeting_id_1, status: status_tardy},
          headers: {
        'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
          }).
        to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_5.json'))
      
      @update_attendance_stub6 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_6}/attendance/update").
        with(
          body: {course_meeting_id: course_meeting_id_1, status: status_tardy},
          headers: {
        'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
          }).
        to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_6.json'))

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
        expect(Honeybadger).to receive(:notify).with("UPDATE FAILED. Student: 24490062, status: absent, response: The specified course_meeting does not exist in this course instance.")
        click_button "Transfer Student Attendances to Populi"  
      end
      
      it 'can handle a populi error when the student is not found' do
        course_offering_id = "10547831"
        enrollment_id_4 = "76296029"
        course_meeting_id_1 = "1962"
        status_absent = "absent"

        # responding with an error that says the student was not found
        @update_attendance_stub4 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_4}/attendance/update").
        with(
          body: {course_meeting_id: course_meeting_id_1, status: status_absent},
          headers: {
        'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
          }).
        to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/error/update_student_attendance_not_found.json'))

        expect(Honeybadger).to receive(:notify).with("UPDATE FAILED. Student: 24490062, status: absent, response: Could not find a coursestudent object with id 76296029")
        
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