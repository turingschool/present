require 'rails_helper'

RSpec.describe 'Modules show page' do
  include ApplicationHelper
  
  before(:each) do
    @user = mock_login
    @test_module = create(:setup_module)
  end

  it 'shows the modules attributes' do
    visit "/modules/#{@test_module.id}"

    expect(page).to have_content("#{@test_module.program} Mod #{@test_module.module_number}")
  end

  context "with attendances" do
    before :each do 
      zoom_attendances = create_list(:zoom_attendance, 3, turing_module: @test_module)
      slack_attendances = create_list(:slack_attendance, 3, turing_module: @test_module)
      @attendances = zoom_attendances + slack_attendances
    end

    it 'shows the past Zoom and Slack attendances for the module' do
      visit "/modules/#{@test_module.id}"

      within('#past-attendances') do
        expect(page).to have_content('Past Attendances')
        @attendances.each do |attendance|
          within("#attendance-#{attendance.id}") do
            expect(page).to have_content(attendance.meeting.title)
            expect(page).to have_content(pretty_date(attendance.attendance_time))
            expect(page).to have_content(pretty_time(attendance.attendance_time))
          end
        end
      end
    end

    it "has a link to each attendance's show page" do
      test_attendance = @attendances.second

      visit "/modules/#{@test_module.id}"
      
      within('#past-attendances') do
        within("#attendance-#{test_attendance.id}") do
          click_link(test_attendance.meeting.title)
          expect(current_path).to eq("/attendances/#{test_attendance.id}")
        end
      end
    end
  end

  it 'mod show page shows link for students and taking attendance once match is done' do 
    visit turing_module_path(@test_module)

    expect(page).to_not have_link("Setup Module")
    expect(page).to have_button("Take Attendance")
  end 

  context 'when setup isnt fully complete' do 
    before(:each) do 
      @test_module = create(:turing_module)
      @channel_id = "C02HRH7MF5K"
    end 

    it 'has a button to set up mod that goes to populi/new page' do
      visit turing_module_path(@test_module)

      have_link('Setup Module', href: turing_module_populi_integration_path(@test_module))
    end

    it 'mod show page still prompts for setup if only populi sync complete' do 
      create(:student, turing_module: @test_module, populi_id: 'some id')

      visit turing_module_path(@test_module)

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_link("Take Attendance")
    end 

    it 'mod show page still prompts for setup if only populi and slack sync complete' do 
      student = create(:setup_student, turing_module: @test_module, slack_id: nil)

      @test_module.students.create(name: 'blah', populi_id: 'some_id')
      @test_module.update(slack_channel_id: 'some_id')

      visit turing_module_path(@test_module)

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_link("Take Attendance")
    end 

    it 'mod show page still prompts for setup if populi, slack, and zoom syncs complete, but match not done' do 
      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))  

      visit turing_module_zoom_integration_path(@test_module)

      fill_in :zoom_meeting_id, with: @zoom_meeting_id
      
      click_button "Import Zoom Accounts From Meeting"

      visit turing_module_path(@test_module)

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_link("Take Attendance")
    end     
  end  
end
