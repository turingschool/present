require 'rails_helper'

RSpec.describe "Module Setup" do
  before(:each) do
    @user = mock_login
    @mod = create(:turing_module, module_number: 2, program: :BE)

    # stub_request(:post, ENV['POPULI_API_URL']).
    #   with(body: {"task"=>"getCurrentAcademicTerm"}).
    #   to_return(status: 200, body: File.read('spec/fixtures/current_academic_term.xml'), headers: {})
    
    # stub_request(:post, ENV['POPULI_API_URL']).
    #   with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295946"}).
    #   to_return(status: 200, body: File.read('spec/fixtures/courses_for_2211.xml'), headers: {})
    
    # stub_request(:post, ENV['POPULI_API_URL']).
    #   with(body: {"task"=>"getCourseInstanceStudents", "instance_id"=>"10547831"}).
    #   to_return(status: 200, body: File.read('spec/fixtures/students_for_be2_2211.xml'), headers: {})
  end

  context 'user has not set up mod' do
    it 'has a button to set up mod that goes to populi/new page' do
      visit turing_module_path(@mod)

      have_link('Setup Module', href: turing_module_populi_integration_path(@mod))
    end
  end


  context 'when setup isnt fully complete' do 
    before(:each) do 
      @zoom_meeting_id = 96428502996
      @channel_id = "C02HRH7MF5K"

      # stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@zoom_meeting_id}/participants?page_size=300") \
      # .to_return(body: File.read('spec/fixtures/participant_report_for_populi.json'))

      # stub_request(:get, "https://api.zoom.us/v2/meetings/#{@zoom_meeting_id}") \
      # .to_return(body: File.read('spec/fixtures/meeting_details_for_populi.json'))

      # stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
      # .to_return(body: File.read('spec/fixtures/slack_channel_members_for_module_setup.json'))
    end 

    it 'mod show page still prompts for setup if only populi sync complete' do 
      @mod.students.create(name: 'blah', populi_id: 'some_id')
      visit turing_module_path(@mod)

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_link("Take Attendance")
    end 

    it 'mod show page still prompts for setup if only populi and slack sync complete' do 
      @mod.students.create(name: 'blah', populi_id: 'some_id')
      @mod.update(slack_channel_id: 'some_id')

      visit turing_module_path(@mod)

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_link("Take Attendance")
    end 

    it 'mod show page still prompts for setup if populi, slack, and zoom syncs complete, but match not done' do 
      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/participant_report_for_populi.json'))
       
      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/meeting_details_for_populi.json'))
        
      visit turing_module_zoom_integration_path(@mod)

      fill_in :zoom_meeting_id, with: @zoom_meeting_id
      
      click_button "Import Zoom Accounts From Meeting"

      visit turing_module_path(@mod)

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_link("Take Attendance")
    end 

    it 'mod show page shows link for students and taking attendance once match is done' do 
      @mod.students.create!(name: 'blah', populi_id: 'some_id', slack_id: 'some_id', zoom_id: 'some_id')
      @mod.update(slack_channel_id: 'some_id')

      visit turing_module_path(@mod)

      expect(page).to_not have_link("Setup Module")
      expect(page).to have_link("Take Attendance")
    end 
  end 


  context 'user has set up populi but not slack' do
    it 'links to slack/new'
  end

  context 'user has set up populi and slack but not zoom' do
    it 'links to zoom/new'
  end
end