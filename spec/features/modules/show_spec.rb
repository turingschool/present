require 'rails_helper'
require './spec/fixtures/populi/stub_requests.rb'

RSpec.describe 'Modules show page' do
  include ApplicationHelper
  
  context "module is set up" do
    before(:each) do
      @user = mock_login
      @test_module = create(:setup_module)
    end

    it 'shows the modules attributes' do
      visit "/modules/#{@test_module.id}"

      expect(page).to have_content("#{@test_module.program} Mod #{@test_module.module_number}")
    end

    it 'has a button to set the module as my_module' do
      visit "/modules/#{@test_module.id}"

      click_button('Set as my Module')

      expect(current_path).to eq(turing_module_path(@test_module))

      expect(page).to_not have_button('Set as my Module')

      expect(@user.turing_module).to eq(@test_module)
    end

    it 'shows link for students and taking attendance if the module is set up' do 
      visit turing_module_path(@test_module)

      expect(page).to_not have_link("Setup Module")
      expect(page).to have_button("Take Attendance")
      expect(page).to have_link("Students (6)", href: turing_module_students_path(@test_module))
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
  end

  context 'when setup isnt fully complete' do 
    before(:each) do 
      stub_call_requests_for_persons
      stub_call_requests_for_course_offerings

      stub_request(:get, "https://turing-validation.populi.co/api2/academicterms/current").
         with(headers: {'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}"}).
         to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term.json')) 
      
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295946"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/courses_for_2211.xml'), headers: {})

      @user = mock_login

      @test_module = create(:turing_module)

      @channel_id = "C02HRH7MF5K"

      visit turing_module_path(@test_module)

      click_button('Set as my Module')
    end 

    it 'user cant take attendance for their mod' do
      visit turing_module_path(@test_module)

      expect(page).to have_link("Setup Module")
      expect(page).to_not have_content('Take Attendance')
    end

    it 'has a button to set up mod that goes to populi/new page' do
      visit turing_module_path(@test_module)

      have_link('Setup Module', href: turing_module_populi_integration_path(@test_module))
    end

    it 'mod show page still prompts for setup if only populi sync complete' do 
      create(:student, turing_module: @test_module, populi_id: 'some id')

      visit turing_module_path(@test_module)

      click_link("Setup Module")

      click_button "Yes"

      visit turing_module_path(@test_module)

      expect(page).to_not have_link("Take Attendance")
      expect(page).to have_link("Setup Module")
    end 

    it 'mod show page still prompts for setup if populi and slack complete but account match not complete' do 
      create(:student, turing_module: @test_module, populi_id: 'some id')

      visit turing_module_path(@test_module)

      click_link("Setup Module")

      click_button "Yes"

      fill_in :slack_channel_id, with: @channel_id

      visit turing_module_path(@test_module)

      expect(page).to_not have_link("Take Attendance")
      expect(page).to have_link("Setup Module")
    end 
  end  
end
