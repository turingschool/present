require 'rails_helper'

RSpec.describe 'Creating a Zoom Attendance' do
  before(:each) do
    @user = mock_login
  end

  context 'with valid meeting ids' do
    before(:each) do
      @test_zoom_meeting_id = 95490216907
      @test_module = create(:setup_module)

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))
    end

    it 'creates a new attendance by filling in a past zoom meeting' do
      visit turing_module_path(@test_module)

      expect(page).to have_content(@test_module.name)
      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
      click_button 'Take Attendance'

      new_attendance = Attendance.last
      expect(current_path).to eq(attendance_path(new_attendance))
      expect(page).to have_content("9:00 AM")
      expect(page).to have_content("January 10th, 2023")
    end

    it 'creates students attendances' do
      absent = @test_module.students.find_by(name: 'Lacey Weaver')
      absent_due_to_tardiness = @test_module.students.find_by(name: 'Anhnhi Tran')
      tardy = @test_module.students.find_by(name: 'J Seymour')
      present = @test_module.students.find_by(name: 'Leo Banos Garcia')
      
      visit turing_module_path(@test_module)

      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
      click_button 'Take Attendance'

      expect(current_path).to eq(attendance_path(Attendance.last))
      expect(page).to have_css('.student-attendance', count: @test_module.students.count)
      expect(find("#student-attendances")).to have_table_row("Student" => absent.name, "Status" => 'absent', "Duration" => "0", "Join Time" => "N/A")
      expect(find("#student-attendances")).to have_table_row("Student" => absent_due_to_tardiness.name, "Status" => 'absent', "Duration" => "63", "Join Time" => "9:31")
      expect(find("#student-attendances")).to have_table_row("Student" => tardy.name, "Status" => 'tardy', "Duration" => "59", "Join Time" => "9:01")
      expect(find("#student-attendances")).to have_table_row("Student" => present.name, "Status" => 'present', "Duration" => "61", "Join Time" => "8:58")
    end

    it 'records the populi attedance start and end times' do
      visit turing_module_path(@test_module)

      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
      click_button 'Take Attendance'
      
      attendance = Attendance.last
      expect(attendance.attendance_time).to eq(DateTime.parse("2023-01-10T09:00:00-07:00"))
      expect(attendance.end_time).to eq(DateTime.parse("2023-01-10T12:00:00-07:00"))
    end
  end

  context "With invalid ids" do
    before :each do
      @invalid_zoom_id = 'InvalidID'
    end

    it 'shows a message if an invalid meeting id is entered' do
      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@invalid_zoom_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details_invalid.json'))

      test_module = create(:setup_module)
      visit turing_module_path(test_module)

      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@invalid_zoom_id}"
      click_button 'Take Attendance'

      expect(current_path).to eq(turing_module_path(test_module))
      expect(page).to have_content("It appears you have entered an invalid Zoom Meeting ID. Please double check the Meeting ID and try again.")
    end

    it 'shows a message if no meeting id is entered' do
      stub_request(:get, "https://api.zoom.us/v2/meetings/") \
        .to_return(body: File.read('spec/fixtures/zoom/endpoint_not_recognized.json'))

      test_module = create(:setup_module)
      visit turing_module_path(test_module)

      click_button 'Take Attendance'
      
      expect(current_path).to eq(turing_module_path(test_module))
      expect(page).to have_content("Please enter a Zoom or Slack link.")
    end

    it 'shows a message if a personal meeting room is entered' do
      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@invalid_zoom_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details_personal_room.json'))

      test_module = create(:setup_module)
      visit turing_module_path(test_module)

      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@invalid_zoom_id}"
      click_button 'Take Attendance'
      
      expect(page).to have_content("It looks like that Zoom link is for a Personal Meeting Room. You will need to use a unique meeting instead.")
    end
  end

  context "With invalid Zoom URLs" do
    it "Shows an error message if the URL isn't continous, has spaces" do
      stub_request(:get, "https://api.zoom.us/v2/meetings/92831928801 928 319 288 01") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details_invalid.json'))

      test_module = create(:setup_module)
      visit turing_module_path(test_module)

      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/92831928801 928 319 288 01"
      click_button 'Take Attendance'
      
      expect(page).to have_content("It appears you have entered an invalid Zoom Meeting ID. Please double check the Meeting ID and try again.")
    end

    it "Shows an error message if the meeting ID in the URL is missing digits." do
      stub_request(:get, "https://api.zoom.us/v2/meetings/9634435576") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details_invalid.json'))

      test_module = create(:setup_module)
      visit turing_module_path(test_module)

      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/9634435576"
      click_button 'Take Attendance'

      expect(page).to have_content("It appears you have entered an invalid Zoom Meeting ID. Please double check the Meeting ID and try again.")
    end
  end

  context "before the participant report is complete" do
    before(:each) do
      @test_zoom_meeting_id = 95490216907
      @test_module = create(:setup_module)

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report_not_ready.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))
    end

    it 'flashes a message letting the user know the report isnt ready yet' do
      visit turing_module_path(@test_module)

      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
      click_button 'Take Attendance'

      expect(page).to have_content("That Zoom Meeting does not have any participants yet. This could be because the meeting is still in progress. Please try again later.")
    end
  end

  context "the participant report is updated" do
    before(:each) do
      @test_zoom_meeting_id = 95490216907
      @test_module = create(:setup_module)

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))
    end

    it "will create the new zoom aliases that weren't in the original report" do
      visit turing_module_path(@test_module)

      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
      click_button 'Take Attendance'

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report_with_extras.json'))

      visit turing_module_path(@test_module)

      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"

      expect { click_button 'Take Attendance' }.to change { ZoomAlias.count }.by(1)
    end
  end
end
