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

    stub_enrollments # Need enrollment ids to update student attendance in Populi
    # see stub_requests.rb for the stubs/ more info 

    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

    stub_course_meetings

    stub_successful_update_student_attendance

    visit turing_module_path(@mod)
    fill_in :attendance_meeting_url, with:  "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
    
    click_button 'Take Attendance'
    
    @test_attendance = Attendance.last
    
    Sidekiq::Testing.inline!
  end

  context "visual display of page for #populi_transfer/new" do
    before :each do
      click_link "Transfer Student Attendances to Populi"
    end

    it 'shows information from the shared meeting view' do
      expect(page).to have_content(@test_attendance.meeting.title)
      expect(page).to have_content(pretty_time(@test_attendance.attendance_time))
      expect(page).to have_content(pretty_date(@test_attendance.attendance_time))
      expect(page).to have_content("Tardy:")
      expect(page).to have_content("Present:")
      expect(page).to have_content("Absent:")
    end

    it 'shows a dropdown to select the time slot' do
      expect(page).to have_content("Please select the attendance time slot to transfer to:")
      expect(page).to have_select(:populi_meeting_id)
    end

    it 'has link to transfer student attendances to populi' do
      expect(page).to have_button("Transfer Student Attendances to Populi")
    end
  end

  context "updates attendance successfully" do
    it 'sends the request to update the students attendance in Populi' do
      stub_successful_update_student_attendance

      click_link "Transfer Student Attendances to Populi"

      expect(current_path).to eq("/attendances/#{@test_attendance.id}/populi_transfer/new")

      expect(page).to have_button("Transfer Student Attendances to Populi")

      expect(page).to have_select(selected: "9:00 AM")

      click_button "Transfer Student Attendances to Populi"

      expect(current_path).to eq(attendance_path(@test_attendance))

      expect(page).to have_content("Transferring attendance to Populi. This could take up to 5 minutes. Please confirm in Populi that the transfer was successful.")

      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76297621/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296027/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296028/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296029/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296030/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296031/attendance/update")
    end    

    it 'can transfer to a different time slot' do
      stub_successful_update_student_attendance
      
      click_link "Transfer Student Attendances to Populi"
      
      expect(page).to have_select(:populi_meeting_id)
      
      select("1:00 PM")
      click_button "Transfer Student Attendances to Populi"

      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76297621/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296027/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296028/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296029/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296030/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296031/attendance/update")
    end
  end

  context "update attendance error" do
    before :each do      
      click_link "Transfer Student Attendances to Populi"
      stub_single_failure_update_student_attendance
      select("9:00 AM")
    end

    it 'keeps processing the job if it encounters an error' do
      click_button "Transfer Student Attendances to Populi"  

      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76297621/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296027/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296028/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296029/attendance/update")# This call errors out, but the job should continue to requests 5 and 6
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296030/attendance/update")
      expect(WebMock).to have_requested(:put, "https://turing-validation.populi.co/api2/courseofferings/10547831/students/76296031/attendance/update")
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
      'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
        }).
      to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/error/update_student_attendance_not_found.json'))
      
      expect(Honeybadger).to receive(:notify).with("UPDATE FAILED. Student: 24490062, status: absent, response: Could not find a coursestudent object with id 76296029")
      
      click_button "Transfer Student Attendances to Populi"  
    end
  end
end