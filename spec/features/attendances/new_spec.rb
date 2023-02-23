require 'rails_helper'

RSpec.describe 'taking attendance' do 
  before(:each) do
    @test_zoom_meeting_id = 95490216907

    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
    .to_return(body: File.read('spec/fixtures/zoom_meeting_participant_report.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
    .to_return(body: File.read('spec/fixtures/zoom_meeting_details.json'))

    @test_module = create(:turing_module)
  end

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
    end

    it 'sends the request to update the students attendance in Populi' do

    end
  end
end