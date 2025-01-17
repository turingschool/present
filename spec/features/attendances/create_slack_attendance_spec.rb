require 'rails_helper'
require './spec/fixtures/populi/test_data/stub_requests.rb'

RSpec.describe 'Creating an Attendance' do
  before(:each) do
    @user = mock_login
  end

  context 'with valid slack url' do
    before(:each) do
      @test_module = create(:setup_module)

      @channel_id = "C02HRH7MF5K"
      @timestamp = "1672861516089859"

      stub_request(:get, "https://slack-attendance-service.turing.edu/api/v0/channel_members?channel_id=#{@channel_id}") \
      .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))

      stub_request(:get, "https://slack-attendance-service.turing.edu/api/v1/attendance?channel_id=#{@channel_id}&timestamp=#{@timestamp}") \
      .to_return(body: File.read('spec/fixtures/slack/message_replies_response.json'))

      stub_course_meetings
      stub_enrollments
      stub_create_student_attendance
    end

    it 'creates a new attendance by providing a slack message link' do
      slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

      visit turing_module_path(@test_module)

      expect(page).to have_content(@test_module.name)

      fill_in :attendance_meeting_url, with: slack_url
      click_button 'Take Attendance'

      new_attendance = Attendance.last
      expect(current_path).to eq(attendance_path(new_attendance))
      expect(page).to have_content("Slack Thread")
      expect(page).to have_content("1:00 PM")
      expect(page).to have_content("November 30th, 2022")
    end

    it 'creates students attendances' do
      absent = @test_module.students.find_by(name: 'Leo Banos Garcia')
      tardy = @test_module.students.find_by(name: "Lacey Weaver")
      absent_due_to_tardiness = @test_module.students.find_by(name: 'J Seymour')
      present = @test_module.students.find_by(name: 'Anhnhi Tran')

      slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

      visit turing_module_path(@test_module)

      fill_in :attendance_meeting_url, with: slack_url
      click_button 'Take Attendance'

      expect(current_path).to eq(attendance_path(Attendance.last))
      expect(page).to have_css('.student-attendance', count: @test_module.students.count)

      expect(find("#student-attendances")).to have_table_row("Student" => absent.name, "Status" => 'absent', "Join Time" => "N/A")
      expect(find("#student-attendances")).to have_table_row("Student" => absent_due_to_tardiness.name, "Status" => 'absent', "Join Time" => "1:30")
      expect(find("#student-attendances")).to have_table_row("Student" => tardy.name, "Status" => 'tardy', "Join Time" => "1:05")
      expect(find("#student-attendances")).to have_table_row("Student" => present.name, "Status" => 'present', "Join Time" => "12:46")
    end

    it 'marks the slack thread as incomplete for presence checks' do
      slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

      visit turing_module_path(@test_module)

      fill_in :attendance_meeting_url, with: slack_url
      click_button 'Take Attendance'

      attendance = Attendance.last

      expect(attendance.meeting.presence_check_complete).to eq(false)
    end

    it 'if populi meeting is not created successfully, it renders to populi_transfer_error_instructions' do
      allow(CreateAttendanceFacade).to receive(:take_attendance).and_raise(InvalidMeetingError.new("Populi meeting was not created successfully."))

      slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

      visit turing_module_path(@test_module)

      expect(page).to have_content(@test_module.name)

      fill_in :attendance_meeting_url, with: slack_url
      click_button 'Take Attendance'

      expect(page).to have_content("To transfer attendance results to Populi, you must first create the Populi attendance record by following these steps:")
      expect(page).to have_content("Populi meeting was not created successfully.")
      expect(page).to have_link("I have created the Attendance record in Populi")
      
      click_link "I have created the Attendance record in Populi"

      expect(current_path).to eq(turing_module_path(@test_module))

      expect(page).to_not have_content("To transfer attendance results to Populi, you must first create the Populi attendance record by following these steps:")
    end
  end
end 