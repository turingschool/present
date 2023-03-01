require 'rails_helper'

RSpec.describe 'taking attendance with Populi' do 
  context 'user has imported students from populi' do
    before :each do
      @user = mock_login
      @mod = create(:setup_module)

      @test_zoom_meeting_id = 96428502996

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom/participant_report_for_populi_automation.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details_for_module_setup.json'))
      
      # intercept each call to update student attendance
      stub_request(:post, "https://turing-validation.populi.co/api/").to_return(status: 200, body: "", headers: {})
     
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceMeetings", "instance_id"=>@mod.populi_course_id}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))
    end

    it 'sends the request to update the students attendance in Populi' do
      visit turing_module_path(@mod)

      click_link('Take Attendance')

      fill_in :attendance_zoom_meeting_id, with: @test_zoom_meeting_id

      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with("10547831", "1962", "24490140", "present")
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with("10547831", "1962", "24490130", "present")
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with("10547831", "1962", "24490100", "absent")
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with("10547831", "1962", "24490062", "present")
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with("10547831", "1962", "24490161", "tardy")
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with("10547831", "1962", "24490123", "tardy")

      click_button 'Take Zoom Attendance'
    end
  end
end