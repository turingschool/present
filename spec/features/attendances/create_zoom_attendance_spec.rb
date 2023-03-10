require 'rails_helper'

RSpec.describe 'Creating a Zoom Attendance' do
  before(:each) do
    @user = mock_login
  end

  it 'links back to module and inning' do
    mod = create(:setup_module)
    inning = mod.inning
    visit new_turing_module_attendance_path(mod)
    expect(page).to have_link(mod.name, href: turing_module_path(mod))
    expect(page).to have_link(inning.name, href: inning_path(inning))
  end

  context 'with valid meeting ids' do
    before(:each) do
      @test_zoom_meeting_id = 95490216907
      @test_module = create(:setup_module)

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details_for_module_setup.json'))

      # Stub any request to update a student's attendance
      stub_request(:post, ENV['POPULI_API_URL']).         
        with(body: {"instanceID"=>/\d/, "meetingID"=>/\d/, "personID"=>/\d/, "status"=>/TARDY|ABSENT|PRESENT/, "task"=>"updateStudentAttendance"},).
        to_return(status: 200, body: '') 

      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))
    end

    it 'creates a new attendance by filling in a past zoom meeting' do
      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      expect(current_path).to eq("/modules/#{@test_module.id}/attendances/new")
      expect(page).to have_content(@test_module.name)
      expect(page).to have_content(@test_module.inning.name)
      expect(page).to have_content('Take Attendance for a Slack Thread or Zoom Meeting')
      fill_in :attendance_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Attendance'

      new_attendance = Attendance.last
      expect(current_path).to eq(attendance_path(new_attendance))
      expect(page).to have_content(@test_zoom_meeting_id)
    end

    it 'creates students attendances' do
      absent = create(:setup_student, turing_module: @test_module)
      absent_due_to_tardiness = @test_module.students.find_by(name: 'Anhnhi Tran')
      tardy = @test_module.students.find_by(name: 'J Seymour')
      present = @test_module.students.find_by(name: 'Leo Banos Garcia')
      
      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      fill_in :attendance_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Attendance'

      expect(current_path).to eq(attendance_path(Attendance.last))

      expect(page).to have_css('.student-attendance', count: @test_module.students.count)

      expect(find("#student-attendances")).to have_table_row("Student" => absent.name, "Status" => 'absent', "Zoom Name" => absent.zoom_name)
      expect(find("#student-attendances")).to have_table_row("Student" => absent_due_to_tardiness.name, "Status" => 'absent', "Zoom Name" => absent_due_to_tardiness.zoom_name)
      expect(find("#student-attendances")).to have_table_row("Student" => tardy.name, "Status" => 'tardy', "Zoom Name" => tardy.zoom_name)
      expect(find("#student-attendances")).to have_table_row("Student" => present.name, "Status" => 'present', "Zoom Name" => present.zoom_name)
    end

    it 'shows a message if an invalid meeting id is entered' do
      invalid_zoom_id = 'InvalidID'
      stub_request(:get, "https://api.zoom.us/v2/meetings/#{invalid_zoom_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details_invalid.json'))

      test_module = create(:turing_module)
      visit new_turing_module_attendance_path(test_module)

      fill_in :attendance_meeting_id, with: invalid_zoom_id
      click_button 'Take Attendance'

      expect(current_path).to eq(new_turing_module_attendance_path(test_module))
      expect(page).to have_content("It appears you have entered an invalid Zoom Meeting ID. Please double check the Meeting ID and try again.")
    end
  end
end
