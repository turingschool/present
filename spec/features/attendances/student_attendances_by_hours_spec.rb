require 'rails_helper'

RSpec.describe 'Student Attendance By Hours' do
  before(:each) do
    @user = mock_login
  end

  context "for zoom attendances" do
    before(:each) do
      @test_zoom_meeting_id = 95490216907
      @test_module = create(:setup_module)

      allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report_for_attendance_hours.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))
    end

    it 'records student_attendance_hours' do
      visit turing_module_path(@test_module)
      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
      click_button 'Take Attendance'
      
      attendance = Attendance.last
      expect(attendance.student_attendance_hours.count).to eq(3 * 6) # This class was 3 hours long and there are 6 students

      leo = Student.find_by(name: "Leo Banos Garcia")
      hours = leo.student_attendance_hours.order(:start)
      expect(hours.first.start).to eq(attendance.attendance_time)
      expect(hours.first.end_time).to eq(attendance.attendance_time + 1.hour)
      expect(hours.first.duration).to eq(60) # Duration greater than or equal to 50 minutes out of the hour counts as present
      expect(hours.first.status).to eq("present")

      expect(hours.second.start).to eq(attendance.attendance_time + 1.hour)
      expect(hours.second.end_time).to eq(attendance.attendance_time + 2.hours)
      expect(hours.second.duration).to eq(60) # Duration greater than 50 minutes out of the hour counts as present
      expect(hours.second.status).to eq("present")

      expect(hours.third.start).to eq(attendance.attendance_time + 2.hours)
      expect(hours.third.end_time).to eq(attendance.end_time)
      expect(hours.third.duration).to eq(49) # Duration less than 50 minutes out of the hour counts as absent
      expect(hours.third.status).to eq("absent")
    end

    it 'the total duration from the hours matches the duration of the parent student attendance record' do
      visit turing_module_path(@test_module)
      fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
      click_button 'Take Attendance'

      leo = Student.find_by(name: "Leo Banos Garcia")
      minutes = leo.student_attendance_hours.sum(:duration)
      expect(leo.student_attendances.last.duration).to eq(minutes)
    end

    context 'class includes a half hour' do
      before :each do
        stub_request(:post, ENV['POPULI_API_URL']).
          with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
          to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings_for_half_hours.xml'))

        visit turing_module_path(@test_module)
        fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
        click_button 'Take Attendance'  
      end

      it 'will create an attendance half hour' do
        attendance = Attendance.last
        expect(attendance.student_attendance_hours.count).to eq(2 * 6) # This class was 1.5 hours long and there are 6 students

        leo = Student.find_by(name: "Leo Banos Garcia")
        hours = leo.student_attendance_hours.order(:start)
        expect(hours.first.start).to eq(attendance.attendance_time)
        expect(hours.first.end_time).to eq(attendance.attendance_time + 1.hour)
        expect(hours.first.duration).to eq(60) # Duration greater than or equal to 50 minutes out of the hour counts as present
        expect(hours.first.status).to eq("present")

        expect(hours.second.start).to eq(attendance.attendance_time + 1.hour)
        expect(hours.second.end_time).to eq(attendance.attendance_time + 1.hour + 30.minutes)
        expect(hours.second.duration).to eq(30) # Duration greater than 50 minutes out of the hour counts as present
        expect(hours.second.status).to eq("present")
      end

      it 'will use the 50/60 minute ratio to determine presence' do
        sam = Student.find_by(name: "Samuel Cox")
        hours = sam.student_attendance_hours.order(:start)
        expect(hours.second.duration).to eq(25) # 25 / 30 minutes meets the ratio of 50/60 minutes for an hour
        expect(hours.second.status).to eq("present")

        anhnhi = Student.find_by(name: "Anhnhi Tran")
        hours = anhnhi.student_attendance_hours.order(:start)
        expect(hours.second.duration).to eq(24) # 24 / 30 minutes is less than the ratio of 50/60 minutes for an hour
        expect(hours.second.status).to eq("absent")
      end
    end
  end

  context "for slack attendances" do
    before :each do 
      @test_module = create(:setup_module)

      @channel_id = "C02HRH7MF5K"
      @timestamp = "1672861516089859"

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
      .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=#{@channel_id}&timestamp=#{@timestamp}") \
      .to_return(body: File.read('spec/fixtures/slack/message_replies_response.json'))

      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"instanceID"=>@test_module.populi_course_id, "task"=>"getCourseInstanceMeetings"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))

      slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

      visit turing_module_path(@test_module)
      fill_in :attendance_meeting_url, with: slack_url
      click_button 'Take Attendance'

      @attendance = Attendance.last

      @leo = Student.find_by(name: "Leo Banos Garcia")
      @present_student = Student.find_by(name: "Anhnhi Tran")
      @absent_student = Student.find_by(name: "Samuel Cox")
      @error_student = Student.find_by(name: "Lacey Weaver")

      36.times do |i|
        check_time = @attendance.attendance_time + 2.minutes + (5.minutes * i) # Checks happen every 5 minutes starting 2 minutes past attendance time
        flaky_presence = i % 5 == 0 ? :active : :away # The flaky student is active for every 5th check starting with the first one
        create(:slack_presence_check, student: @leo, check_time: check_time, presence: flaky_presence)
        create(:slack_presence_check, student: @present_student, check_time: check_time, presence: :active)
        create(:slack_presence_check, student: @absent_student, check_time: check_time, presence: :away)
      end
      # For the flaky student, the end result is that they are present for 3/4 of the 15 minute checks of the first hour,
      # 2/4 of the 15 minute checks of the second hour, and 3/4 of the 15 minute checks of the third hour

      @test_module.inning.process_presence_data_for_slack_attendances! # manually call this method. In production this will be called from a cron job
    end

    it 'records student_attendance_hours' do
      expect(@attendance.student_attendance_hours.count).to eq(3 * 6) # This class was 3 hours long and there are 6 students

      expect(@leo.student_attendance_hours.first.duration).to eq(45)
      expect(@leo.student_attendance_hours.first.status).to eq("absent")
      expect(@leo.student_attendance_hours.second.duration).to eq(30)
      expect(@leo.student_attendance_hours.second.status).to eq("absent")
      expect(@leo.student_attendance_hours.third.duration).to eq(45)
      expect(@leo.student_attendance_hours.third.status).to eq("absent")
      
      expect(@present_student.student_attendance_hours.first.duration).to eq(60)
      expect(@present_student.student_attendance_hours.first.status).to eq("present")
      expect(@present_student.student_attendance_hours.second.duration).to eq(60)
      expect(@present_student.student_attendance_hours.second.status).to eq("present")
      expect(@present_student.student_attendance_hours.third.duration).to eq(60)
      expect(@present_student.student_attendance_hours.third.status).to eq("present")
      
      expect(@absent_student.student_attendance_hours.first.duration).to eq(0)
      expect(@absent_student.student_attendance_hours.first.status).to eq("absent")
      expect(@absent_student.student_attendance_hours.second.duration).to eq(0)
      expect(@absent_student.student_attendance_hours.second.status).to eq("absent")
      expect(@absent_student.student_attendance_hours.third.duration).to eq(0)
      expect(@absent_student.student_attendance_hours.third.status).to eq("absent")
      
      expect(@error_student.student_attendance_hours.first.duration).to eq(0)
      expect(@error_student.student_attendance_hours.first.status).to eq("absent")
      expect(@error_student.student_attendance_hours.second.duration).to eq(0)
      expect(@error_student.student_attendance_hours.second.status).to eq("absent")
      expect(@error_student.student_attendance_hours.third.duration).to eq(0)
      expect(@error_student.student_attendance_hours.third.status).to eq("absent")
    end

    it 'marks the slack thread presence check as complete' do
      expect(@attendance.meeting.presence_check_complete).to eq(true)
    end
  end
end