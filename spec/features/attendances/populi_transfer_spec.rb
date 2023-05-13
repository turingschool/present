require 'rails_helper'
require 'sidekiq/testing' 

RSpec.describe 'Populi Transfer' do 
  include ApplicationHelper

  before :each do
    @user = mock_login
    @mod = create(:setup_module)

    @test_zoom_meeting_id = 96428502996

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
      # Assume that the User has followed instructions to create attendance record in Populi. The corresponding meeting should be returned from the Populi API with a meetingID.
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@mod.populi_course_id}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))
      
    end

    context "update successful" do
      it 'sends the request to update the students attendance in Populi' do
        update_response = File.read('spec/fixtures/populi/update_student_attendance_success.xml')

        @update_attendance_stub1 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490140", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        @update_attendance_stub2 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490130", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        # Absent
        @update_attendance_stub3 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490100", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        # Absent due to tardiness
        @update_attendance_stub4 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490062", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        @update_attendance_stub5 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490161", "status"=>"TARDY", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 
        @update_attendance_stub6 = stub_request(:post, ENV['POPULI_API_URL']).         
          with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490123", "status"=>"TARDY", "task"=>"updateStudentAttendance"},).
          to_return(status: 200, body: update_response) 

        click_link "Transfer Student Attendances to Populi"

        expect(current_path).to eq("/attendances/#{@test_attendance.id}/populi_transfer/new")

        expect(page).to have_content(@test_attendance.meeting.title)
        expect(page).to have_content(pretty_time(@test_attendance.attendance_time))
        expect(page).to have_content(pretty_date(@test_attendance.attendance_time))
        expect(page).to have_content("Tardy: 2")
        expect(page).to have_content("Present: 2")
        expect(page).to have_content("Absent: 2")

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
      it 'can handle a failure response from Populi' do
        stub_request(:post, ENV['POPULI_API_URL']) \
          .with{|request| request.body.include? "updateStudentAttendance"} \
          .to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_error.xml')) 

        visit turing_module_path(@mod)

        fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
                    
        click_button 'Take Attendance'

        click_link "Transfer Student Attendances to Populi"

        

        expect {click_button "Transfer Student Attendances to Populi"}.to raise_exception
      end
    end    
  end

  context "user doesn't follow instructions" do # Populi meeting won't have an id

  end
end