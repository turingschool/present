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

    @update_attendance_stub1 = stub_request(:post, ENV['POPULI_API_URL']).         
      with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490140", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
      to_return(status: 200, body: '') 
    @update_attendance_stub2 = stub_request(:post, ENV['POPULI_API_URL']).         
      with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490130", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
      to_return(status: 200, body: '') 
    # Absent
    @update_attendance_stub3 = stub_request(:post, ENV['POPULI_API_URL']).         
      with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490100", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
      to_return(status: 200, body: '') 
    # Absent due to tardiness
    @update_attendance_stub4 = stub_request(:post, ENV['POPULI_API_URL']).         
      with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490062", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
      to_return(status: 200, body: '') 
    @update_attendance_stub5 = stub_request(:post, ENV['POPULI_API_URL']).         
      with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490161", "status"=>"TARDY", "task"=>"updateStudentAttendance"},).
      to_return(status: 200, body: '') 
    @update_attendance_stub6 = stub_request(:post, ENV['POPULI_API_URL']).         
      with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490123", "status"=>"TARDY", "task"=>"updateStudentAttendance"},).
      to_return(status: 200, body: '') 

    Sidekiq::Testing.inline!
  end

  it 'sends the request to update the students attendance in Populi' do
    visit turing_module_path(@mod)

    fill_in :attendance_meeting_url, with:  "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
                
    click_button 'Take Attendance'

    test_attendance = Attendance.last

    click_link "Transfer Student Attendances to Populi"

    expect(current_path).to eq("/attendances/#{test_attendance.id}/populi_transfer/new")

    expect(page).to have_content(test_attendance.meeting.title)
    expect(page).to have_content(pretty_time(test_attendance.attendance_time))
    expect(page).to have_content(pretty_date(test_attendance.attendance_time))
    expect(page).to have_content("Tardy: 2")
    expect(page).to have_content("Present: 2")
    expect(page).to have_content("Absent: 2")

    # Assume that the User has followed instructions to create attendance record in Populi. The corresponding meeting should be returned from the Populi API with a meetingID.
    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@mod.populi_course_id}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))

    click_button "Transfer Student Attendances to Populi"

    expect(current_path).to eq(attendance_path(test_attendance))

    expect(page).to have_content("Transferring attendance to Populi")

    expect(@update_attendance_stub1).to have_been_requested
    expect(@update_attendance_stub2).to have_been_requested
    expect(@update_attendance_stub3).to have_been_requested
    expect(@update_attendance_stub4).to have_been_requested
    expect(@update_attendance_stub5).to have_been_requested
    expect(@update_attendance_stub6).to have_been_requested
  end

  it 'can transfer to a different time slot'

  it 'can handle a failure response from Populi'
end