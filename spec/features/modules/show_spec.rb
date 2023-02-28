require 'rails_helper'

RSpec.describe 'Modules show page' do
  before(:each) do
    @user = mock_login
    @test_module = create(:turing_module)
  end

  it 'shows the modules attributes' do
    
    create_list(:student, 5, turing_module: @test_module)

    visit "/modules/#{@test_module.id}"

    expect(page).to have_content("#{@test_module.program} Mod #{@test_module.module_number}")
    expect(page).to have_content("#{@test_module.inning.name} inning")
  end

  it 'shows the past zoom attendances for the module' do

    create_list(:student, 5, turing_module: @test_module)

    attendances = create_list(:zoom_attendance, 3).map do |zoom_attendance|
      zoom_attendance.attendance.update(turing_module: @test_module)
      zoom_attendance.attendance
    end 

    visit "/modules/#{@test_module.id}"

    within('#past-attendances') do
      expect(page).to have_content('Past Attendances')
      attendances.each do |attendance|
        within("#attendance-#{attendance.id}") do
          expect(page).to have_content(attendance.zoom_attendance.meeting_time)
          expect(page).to have_content(attendance.zoom_attendance.meeting_title)
          expect(page).to have_content(attendance.zoom_attendance.zoom_meeting_id)
        end
      end
    end
  end

  it 'shows the past slack attendances for the module' do

    create_list(:student, 5, turing_module: @test_module)

    attendances = create_list(:slack_attendance, 3).map do |slack_attendance|
      slack_attendance.attendance.update(turing_module: @test_module)
      slack_attendance.attendance
    end 

    visit "/modules/#{@test_module.id}"

    within('#past-attendances') do
      expect(page).to have_content('Past Attendances')
      attendances.each do |attendance|
        within("#attendance-#{attendance.id}") do
          # expect(page).to have_link(attendance.slack_attendance.pretty_time_date, href: attendance_path(attendance))
          expect(page).to have_content(attendance.slack_attendance.attendance_start_time)
        end
      end
    end
  end

  it "has a link to each attendance's show page" do

    create_list(:student, 5, turing_module: @test_module)

    attendances = create_list(:zoom_attendance, 3).map do |zoom_attendance|
      zoom_attendance.attendance.update(turing_module: @test_module)
      zoom_attendance.attendance
    end 

    test_attendance = attendances[1]

    visit "/modules/#{@test_module.id}"

    within('#past-attendances') do
      within("#attendance-#{test_attendance.id}") do
        click_link(test_attendance.zoom_attendance.meeting_title)
        expect(current_path).to eq("/attendances/#{test_attendance.id}")
      end
    end
  end

  it 'has a message if module is already set as My Module' do
    @user.turing_module = @test_module

    visit turing_module_path(@test_module)

    expect(page).to have_content('(Set to My Module)')
  end

  it 'has a button to set the module as my_module' do
    visit turing_module_path(@test_module)

    click_button 'Set as My Module'

    expect(current_path).to eq(turing_module_path(@test_module))
    expect(page).to have_content('(Set to My Module)')
    expect(@user.is_this_my_mod?(@test_module)).to eq(true)
  end


   context 'user has not set up mod' do
    it 'has a button to set up mod that goes to populi/new page' do
      visit turing_module_path(@test_module)

      have_link('Setup Module', href: turing_module_populi_integration_path(@test_module))
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
      @test_module.students.create(name: 'blah', populi_id: 'some_id')
      visit turing_module_path(@test_module)

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_link("Take Attendance")
    end 

    it 'mod show page still prompts for setup if only populi and slack sync complete' do 
      @test_module.students.create(name: 'blah', populi_id: 'some_id')
      @test_module.update(slack_channel_id: 'some_id')

      visit turing_module_path(@test_module)

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_link("Take Attendance")
    end 

    it 'mod show page still prompts for setup if populi, slack, and zoom syncs complete, but match not done' do 
      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/participant_report_for_populi.json'))
       
      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/meeting_details_for_populi.json'))

      visit turing_module_zoom_integration_path(@test_module)

      fill_in :zoom_meeting_id, with: @zoom_meeting_id
      
      click_button "Import Zoom Accounts From Meeting"

      visit turing_module_path(@test_module)

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_link("Take Attendance")
    end 

    it 'mod show page shows link for students and taking attendance once match is done' do 
      @test_module.students.create!(name: 'blah', populi_id: 'some_id', slack_id: 'some_id', zoom_id: 'some_id')
      @test_module.update(slack_channel_id: 'some_id')

      visit turing_module_path(@test_module)

      expect(page).to_not have_link("Setup Module")
      expect(page).to have_link("Take Attendance")
    end 
  end  
end
