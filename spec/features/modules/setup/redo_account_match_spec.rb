require 'rails_helper'

RSpec.describe "Redo Module Setup Account Matching" do
  context 'user can choose to redo module setup after its already been done' do
    before :each do
      @user = mock_login
      @test_module = create(:setup_module, module_number: 2, program: :BE)
      @channel_id = "C02HRH7MF5K" 
      @zoom_meeting_id = 96428502996

      stub_request(:get, "https://turing-validation.populi.co/api2/academicterms/current").
         with(headers: {'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}"}).
         to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term.json')) 
      
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295946"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/courses_for_2211.xml'), headers: {})
      
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceStudents", "instance_id"=>"10547831"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/students_for_be2_2211.xml'), headers: {})

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))  

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
        .to_return(body: File.read('spec/fixtures/slack/channel_members_for_module_setup.json'))
    end 
  
    it 'has option on mod show page to redo mod setup', js: true do 
      expect(@test_module.students.count).to eq(6) #there are 6 students created from the factory

      visit turing_module_path(@test_module)

      accept_alert do
        click_link "Redo Module Setup"
      end
      
      within '#best-match' do
        click_button 'Yes'
      end

      fill_in :slack_channel_id, with: @channel_id
      click_button "Import Channel"

      click_button 'Connect Accounts'

      @test_module.reload
      
      expect(@test_module.students.count).to eq(7) #there are 7 students in the populi fixture file.
      expect(current_path).to eq(turing_module_path(@test_module))
      expect(@test_module.attendances.count).to eq(0)
    end 

    it 'does not destroy student records' do
      original_ids = Student.pluck(:id)

      visit turing_module_path(@test_module)

      click_link "Redo Module Setup"

      within '#best-match' do
        click_button 'Yes'
      end

      fill_in :slack_channel_id, with: @channel_id
      click_button "Import Channel"

      click_button 'Connect Accounts'

      # All the student ids that existed before the redo should still exist
      expect(Student.where(id: original_ids).count).to eq(original_ids.length)
    end

    it 'removes any students that were part of the module before the redo' do
      new_student = create(:student)

      @test_module.students << new_student

      visit turing_module_path(@test_module)

      click_link "Redo Module Setup"

      within '#best-match' do
        click_button 'Yes'
      end

      fill_in :slack_channel_id, with: @channel_id
      click_button "Import Channel"

      click_button 'Connect Accounts'

      expect(@test_module.students).to_not include(new_student)
    end
  end
end