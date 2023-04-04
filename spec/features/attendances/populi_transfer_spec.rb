require 'rails_helper'

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
      to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))

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
  end


# And I see there are instructions informing me that I first need to first create the attendance in Populi 
# by marking all students as absent, clicking the correct check boxes for whether or not the attendance 
# fulfills attendance hours and/or clinical hours, and clicking "Save Attendance".

# And I see a button to confirm "I have created the Attendance record in Populi".
# When I click this button,
# Then I see that button is inactive,
# And I see there is a new button for "Transfer Student Attendance to Populi" that was inactive is now active.
# When I click that button,
# Then I am redirected to the attendance's show page,
# And I see a confirmation that the attendance was saved successfully.
# And when I view the corresponding attendance record in Populi,
# Then I see the attendance is updated accurately.

  it 'sends the request to update the students attendance in Populi' do
    visit turing_module_path(@mod)

    click_link('Take Attendance')

    fill_in :attendance_meeting_url, with:  "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
                
    click_button 'Take Attendance'

    test_attendance = Attendance.last

    click_link "Transfer Student Attendances to Populi"

    expect(current_path).to eq("/attendances/#{test_attendance.id}/populi_transfer")

    expect(page).to have_content(test_attendance.meeting.title)
    expect(page).to have_content(pretty_time(test_attendance.attendance_time))
    expect(page).to have_content(pretty_date(test_attendance.attendance_time))
    expect(page).to have_content("Tardy: 2")
    expect(page).to have_content("Present: 2")
    expect(page).to have_content("Absent: 2")
    save_and_open_page
    click_button "I have created the Attendance record in Populi"

    expect(current_path).to eq("/attendances/#{test_attendance.id}/populi_transfer")
    save_and_open_page
    click_button "Transfer Student Attendances to Populi"

    expect(current_path).to eq(attendance_path(test_attendance))

    expect(page).to have_content("Success! Student Attendances have been transferred to Populi. Please double check that the attendance in Populi is accurate.")

    expect(@update_attendance_stub1).to have_been_requested
    expect(@update_attendance_stub2).to have_been_requested
    expect(@update_attendance_stub3).to have_been_requested
    expect(@update_attendance_stub4).to have_been_requested
    expect(@update_attendance_stub5).to have_been_requested
    expect(@update_attendance_stub6).to have_been_requested
  end
end