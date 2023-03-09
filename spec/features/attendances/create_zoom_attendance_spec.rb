require 'rails_helper'

RSpec.describe 'Creating a Zoom Attendance' do
  before(:each) do
    @user = mock_login
  end

  it 'links back to module and inning' do
    mod = create(:turing_module)
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
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

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

    xit 'can populate the module with students from the Zoom meeting' do
      visit turing_module_path(test_module)
      expect(page).to have_link('Students (0)')
      click_link('Take Attendance')

      check(:attendance_populate_students)
      fill_in :attendance_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Attendance'

      visit turing_module_path(test_module)
      click_link("Students (#{expected_students.length})")

      expect(page).to have_css('.student', count: expected_students.length)
      expected_students.each do |student|
        expect(page).to have_content(student.name)
        expect(page).to have_content(student.zoom_id)
      end
    end

    xit 'can prompt user to add a new user if zoom attendee is not in student list' do
      new_student = expected_students.pop
      @test_module.students = expected_students
      
      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      fill_in :attendance_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Attendance'

      visit "/attendances/#{Attendance.last.id}"

      expect(@test_module.students.count).to eq(42)
      expect(page).to have_button("Add New Student")

      click_button "Add New Student"

      expect(current_path).to eq(attendance_path(Attendance.last))

      expect(@test_module.students.count).to eq(43)
      expect(@test_module.students.exists?(name: new_student.name)).to be(true)

      visit turing_module_students_path(@test_module)

      expect(page).to have_link(new_student.name)

      visit "/attendances/#{Attendance.last.id}"

      expect(page).to_not have_button("Add New Student")
    end

    xit 'can add students to the module even if they are associated with another module' do
      new_student = expected_students.pop
      other_mod = create(:turing_module)
      new_student.update(turing_module: other_mod)
      @test_module.students = expected_students

      visit turing_module_path(@test_module)
      click_link('Take Attendance')
      fill_in :attendance_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Attendance'

      visit "/attendances/#{Attendance.last.id}"

      expect(@test_module.students.count).to eq(42)
      expect(page).to have_button("Add New Student")

      click_button "Add New Student"

      visit turing_module_students_path(@test_module)

      expect(page).to have_link(new_student.name)

      visit turing_module_students_path(other_mod)

      expect(page).to_not have_link(new_student.name)
    end

    it 'creates students attendances' do
      absent_student = create(:student, turing_module: @test_module)

      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      fill_in :attendance_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Attendance'

      visit "/attendances/#{Attendance.last.id}"

      expect(Attendance.last.student_attendances.count).to eq(@test_module.students.count)

      Attendance.last.student_attendances.each do |student_attendance|
        student = student_attendance.student
        expect(find("#student-attendances")).to have_table_row("Student" => student.name, "Status" => student_attendance.status, "Zoom ID" => student.zoom_id)
      end
      expect(find("#student-attendances")).to have_table_row("Student" => absent_student.name, "Status" => 'absent', "Zoom ID" => absent_student.zoom_id)
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
