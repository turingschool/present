require 'rails_helper'

RSpec.describe 'taking attendance with Populi' do 
  context 'user has imported students from populi' do
    before :each do
      @user = mock_login
      @mod = create(:turing_module, module_number: 2, program: :BE)
      @student_1 = create(:student, turing_module: @mod, name: 'Leo BG# BE', populi_id: 24490130)
      @student_2 = create(:student, turing_module: @mod, name: 'Anthony B. (He/Him) BE 2210', populi_id: 24490140)
      @student_3 = create(:student, turing_module: @mod, name: 'Lacey W (she/her)', populi_id: 24490100)
      @student_4 = create(:student, turing_module: @mod, name: 'Anhnhi T# BE', populi_id: 24490062)
      @student_5 = create(:student, turing_module: @mod, name: 'J Seymour (he/they) BE', populi_id: 24490161)
      @student_6 = create(:student, turing_module: @mod, name: 'Mike C. (he/him) BE', populi_id: 24490150)
      @student_7 = create(:student, turing_module: @mod, name: 'Samuel C (He/Him) BE', populi_id: 24490123)

      @test_zoom_meeting_id = 96428502996

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom/participant_report_for_module_setup.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/meeting_details_for_populi.json'))

      @test_module = create(:turing_module)
    end

    xit 'sends the request to update the students attendance in Populi' do
      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      fill_in :attendance_zoom_meeting_id, with: @test_zoom_meeting_id

      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with(24490130, :present)
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with(24490140, :present)
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with(24490100, :present)
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with(24490062, :present)
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with(24490161, :tardy)
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with(24490150, :absent)
      expect_any_instance_of(PopuliService).to receive(:update_student_attendance).with(24490123, :present)
    end
  end
end