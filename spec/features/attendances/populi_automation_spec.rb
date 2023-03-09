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
     
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@mod.populi_course_id}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))

      @update_attendance_stub1 = stub_request(:post, ENV['POPULI_API_URL']).         
        with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490140", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
        to_return(status: 200, body: '') 
      @update_attendance_stub2 = stub_request(:post, ENV['POPULI_API_URL']).         
        with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490130", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
        to_return(status: 200, body: '') 
      @update_attendance_stub3 = stub_request(:post, ENV['POPULI_API_URL']).         
        with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490100", "status"=>"ABSENT", "task"=>"updateStudentAttendance"},).
        to_return(status: 200, body: '') 
      @update_attendance_stub4 = stub_request(:post, ENV['POPULI_API_URL']).         
        with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490062", "status"=>"PRESENT", "task"=>"updateStudentAttendance"},).
        to_return(status: 200, body: '') 
      @update_attendance_stub5 = stub_request(:post, ENV['POPULI_API_URL']).         
        with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490161", "status"=>"TARDY", "task"=>"updateStudentAttendance"},).
        to_return(status: 200, body: '') 
      @update_attendance_stub6 = stub_request(:post, ENV['POPULI_API_URL']).         
        with(body: {"instanceID"=>"10547831", "meetingID"=>"1962", "personID"=>"24490123", "status"=>"TARDY", "task"=>"updateStudentAttendance"},).
        to_return(status: 200, body: '') 
    end

    it 'sends the request to update the students attendance in Populi' do
      visit turing_module_path(@mod)

      click_link('Take Attendance')

      fill_in :attendance_meeting_id, with: @test_zoom_meeting_id
                  
      click_button 'Take Attendance'

      expect(@update_attendance_stub1).to have_been_requested
      expect(@update_attendance_stub2).to have_been_requested
      expect(@update_attendance_stub3).to have_been_requested
      expect(@update_attendance_stub4).to have_been_requested
      expect(@update_attendance_stub5).to have_been_requested
      expect(@update_attendance_stub6).to have_been_requested
    end
  end
end