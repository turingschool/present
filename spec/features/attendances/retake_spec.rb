require 'rails_helper'
require './spec/fixtures/populi/test_data/stub_requests.rb'

RSpec.describe 'Retaking Attendance' do
  before(:each) do
    @user = mock_login
  end

  context 'for an existing zoom attendance' do
    before(:each) do
      @test_zoom_meeting_id = 95490216907
      @test_module = create(:setup_module)

      allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

      stub_course_meetings

      visit turing_module_path(@test_module)

      fill_in :attendance_meeting_url, with: @test_zoom_meeting_id
      click_button 'Take Attendance'
    end

    context "clicking the retake button" do

      it 'accurately records attendance' do
        absent = @test_module.students.find_by(name: 'Lacey Weaver')
        absent_due_to_tardiness = @test_module.students.find_by(name: 'Anhnhi Tran')
        tardy = @test_module.students.find_by(name: 'J Seymour')
        present = @test_module.students.find_by(name: 'Leo Banos Garcia')

        click_button "Retake Attendance"

        expect(current_path).to eq(attendance_path(Attendance.last))
        expect(page).to have_css('.student-attendance', count: @test_module.students.count)
        expect(find("#student-attendances")).to have_table_row("Student" => absent.name, "Status" => 'absent', "Duration" => "0", "Join Time" => "N/A")
        expect(find("#student-attendances")).to have_table_row("Student" => absent_due_to_tardiness.name, "Status" => 'absent', "Duration" => "63", "Join Time" => "9:31")
        expect(find("#student-attendances")).to have_table_row("Student" => tardy.name, "Status" => 'tardy', "Duration" => "59", "Join Time" => "9:01")
        expect(find("#student-attendances")).to have_table_row("Student" => present.name, "Status" => 'present', "Duration" => "59", "Join Time" => "8:58")
      end

      it 'does not duplicate zoom meeting records' do
        visit turing_module_path(@test_module)

        fill_in :attendance_meeting_url, with: @test_zoom_meeting_id
        click_button 'Take Attendance'
        expect { click_button "Retake Attendance" }.to_not change { ZoomMeeting.count }
      end

      it 'does not duplicate attendance records' do
        visit turing_module_path(@test_module)

        fill_in :attendance_meeting_url, with: @test_zoom_meeting_id
        click_button 'Take Attendance'
        expect { click_button "Retake Attendance" }.to_not change { Attendance.count }
      end
    end

    context "filling in the same zoom meeting id" do
      it 'will not duplicate attendance records' do  
        visit turing_module_path(@test_module)
        fill_in :attendance_meeting_url, with: @test_zoom_meeting_id

        expect { click_button 'Take Attendance' }.to_not change { Attendance.count }
      end

      it 'does not duplicate zoom meeting records' do
        visit turing_module_path(@test_module)
        fill_in :attendance_meeting_url, with: @test_zoom_meeting_id

        expect { click_button 'Take Attendance' }.to_not change { ZoomMeeting.count }
      end

      it 'will not duplicate if a different user takes attendance' do
        mock_login # Creates and logs in a new user
        
        visit turing_module_path(@test_module)
        fill_in :attendance_meeting_url, with: @test_zoom_meeting_id

        expect { click_button 'Take Attendance' }.to_not change { Attendance.count }
      end
    end
  end

  context "for a slack thread" do
    before(:each) do
      @test_module = create(:setup_module)
      
      @channel_id = "C02HRH7MF5K"
      @timestamp = "1672861516089859"
      @slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
        .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=#{@channel_id}&timestamp=#{@timestamp}") \
        .to_return(body: File.read('spec/fixtures/slack/message_replies_response.json'))

      stub_course_meetings
    end

    it 'has a button to retake attendance' do
      absent = @test_module.students.find_by(name: 'Leo Banos Garcia')
      tardy = @test_module.students.find_by(name: "Lacey Weaver")
      absent_due_to_tardiness = @test_module.students.find_by(name: 'J Seymour')
      present = @test_module.students.find_by(name: 'Anhnhi Tran')

      visit turing_module_path(@test_module)

      fill_in :attendance_meeting_url, with: @slack_url
      click_button 'Take Attendance'

      click_button 'Retake Attendance'

      expect(current_path).to eq(attendance_path(Attendance.last))
      expect(page).to have_css('.student-attendance', count: @test_module.students.count)

      expect(find("#student-attendances")).to have_table_row("Student" => absent.name, "Status" => 'absent', "Join Time" => "N/A")
      expect(find("#student-attendances")).to have_table_row("Student" => absent_due_to_tardiness.name, "Status" => 'absent', "Join Time" => "1:30")
      expect(find("#student-attendances")).to have_table_row("Student" => tardy.name, "Status" => 'tardy', "Join Time" => "1:05")
      expect(find("#student-attendances")).to have_table_row("Student" => present.name, "Status" => 'present', "Join Time" => "12:46")
    end

    it 'does not duplicate attendance records' do
      visit turing_module_path(@test_module)

      fill_in :attendance_meeting_url, with: @slack_url

      click_button 'Take Attendance'
      expect { click_button "Retake Attendance" }.to_not change { Attendance.count }
    end

    it 'can retake attendance by filling in the same slack thread url' do
      visit turing_module_path(@test_module)
      fill_in :attendance_meeting_url, with: @slack_url

      click_button 'Take Attendance'

      visit turing_module_path(@test_module)
      fill_in :attendance_meeting_url, with: @slack_url

      expect { click_button 'Take Attendance' }.to_not change { Attendance.count }
    end
  end
end