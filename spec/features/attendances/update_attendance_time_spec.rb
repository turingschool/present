require 'rails_helper'

RSpec.describe 'Attendance Update' do
  before(:each) do
    @user = mock_login
    @test_zoom_meeting_id = 95490216907
    @test_module = create(:setup_module)

    allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token
    
    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom/participant_report_for_attendance_update.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))

    visit turing_module_path(@test_module)

    fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"

    click_button 'Take Attendance'

    @attendance = Attendance.last  
  end

  it 'Has a link to update the attendance time from the show page' do
    visit attendance_path(@attendance)

    click_link "Update Attendance Time"

    expect(current_path).to eq(edit_attendance_path(@attendance))
  end

  it 'Can update the attendance time and retake attendance' do
    lacey = @test_module.students.find_by(name: 'Lacey Weaver')
    anhnhi = @test_module.students.find_by(name: 'Anhnhi Tran')
    j = @test_module.students.find_by(name: 'J Seymour')
    leo = @test_module.students.find_by(name: 'Leo Banos Garcia')

    visit attendance_path(@attendance)

    expect(find("#student-attendances")).to have_table_row("Student" => lacey.name, "Status" => 'absent')
    expect(find("#student-attendances")).to have_table_row("Student" => anhnhi.name, "Status" => 'absent')
    expect(find("#student-attendances")).to have_table_row("Student" => leo.name, "Status" => 'absent')
    expect(find("#student-attendances")).to have_table_row("Student" => j.name, "Status" => 'tardy')

    visit edit_attendance_path(@attendance)

    fill_in :attendance_attendance_time, with: "9:30"

    click_button 'Update Attendance Time'

    expect(current_path).to eq(attendance_path(@attendance))
    expect(find("#student-attendances")).to have_table_row("Student" => lacey.name, "Status" => 'absent')
    expect(find("#student-attendances")).to have_table_row("Student" => anhnhi.name, "Status" => 'tardy')
    expect(find("#student-attendances")).to have_table_row("Student" => leo.name, "Status" => 'present')
    expect(find("#student-attendances")).to have_table_row("Student" => j.name, "Status" => 'present')
  end

  it 'can move attendance backward in time' do
    sam = @test_module.students.find_by(name: 'Samuel Cox')
    anthony = @test_module.students.find_by(name: 'Anthony Blackwell Tallent')

    visit attendance_path(@attendance)

    expect(find("#student-attendances")).to have_table_row("Student" => sam.name, "Status" => 'present')
    expect(find("#student-attendances")).to have_table_row("Student" => anthony.name, "Status" => 'tardy')

    visit edit_attendance_path(@attendance)

    
    fill_in :attendance_attendance_time, with: "8:55"

    click_button 'Update Attendance Time'

    expect(find("#student-attendances")).to have_table_row("Student" => sam.name, "Status" => 'tardy')
    expect(find("#student-attendances")).to have_table_row("Student" => anthony.name, "Status" => 'absent')
  end
end
