require 'rails_helper'

RSpec.describe 'Creating an Attendance' do
  before(:each) do
    @user = mock_login
  end
  
  context 'with valid slack url' do
    before(:each) do
      @test_module = create(:setup_module)
      
      @channel_id = "C02HRH7MF5K"
      @timestamp = "1672861516089859"

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
      .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=#{@channel_id}&timestamp=#{@timestamp}") \
      .to_return(body: File.read('spec/fixtures/slack/message_replies_response.json'))

      # Stub any request to update a student's attendance
      stub_request(:post, ENV['POPULI_API_URL']).         
        with(body: {"instanceID"=>/\d/, "meetingID"=>/\d/, "personID"=>/\d/, "status"=>/TARDY|ABSENT|PRESENT/, "task"=>"updateStudentAttendance"},).
        to_return(status: 200, body: '') 

      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"instanceID"=>@test_module.populi_course_id, "task"=>"getCourseInstanceMeetings"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))
    end

    it 'creates a new attendance by providing a slack message link' do
      slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      expect(current_path).to eq("/modules/#{@test_module.id}/attendances/new")
      expect(page).to have_content(@test_module.name)
      expect(page).to have_content(@test_module.inning.name)
      expect(page).to have_content('Take Attendance for a Slack Thread')

      fill_in :attendance_meeting_url, with: slack_url
      click_button 'Take Attendance'

      new_attendance = Attendance.last
      expect(current_path).to eq(attendance_path(new_attendance))
      expect(page).to have_content("Slack Thread")
      # expect(page).to have_content("Slack Message URL - #{slack_url}) future idea to have this on this page
      expect(page).to have_content("1:00 PM")
      expect(page).to have_content("Nov 30, 2022")
    end

    it 'creates students attendances' do
      absent = @test_module.students.find_by(name: 'Leo Banos Garcia')
      tardy = @test_module.students.find_by(name: "Lacey Weaver")
      absent_due_to_tardiness = @test_module.students.find_by(name: 'J Seymour')
      present = @test_module.students.find_by(name: 'Anhnhi Tran')

      slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      fill_in :attendance_meeting_url, with: slack_url
      click_button 'Take Attendance'

      expect(current_path).to eq(attendance_path(Attendance.last))
      expect(page).to have_css('.student-attendance', count: @test_module.students.count)

      expect(find("#student-attendances")).to have_table_row("Student" => absent.name, "Status" => 'absent')
      expect(find("#student-attendances")).to have_table_row("Student" => absent_due_to_tardiness.name, "Status" => 'absent')
      expect(find("#student-attendances")).to have_table_row("Student" => tardy.name, "Status" => 'tardy')
      expect(find("#student-attendances")).to have_table_row("Student" => present.name, "Status" => 'present')
    end
  end

  it 'sad path'
end 