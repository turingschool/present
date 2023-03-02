require 'rails_helper'

RSpec.describe "Module Setup Account Matching" do
  context 'user imports students from populi, imports a slack channel, and imports participants from a zoom meeting' do
    before :each do
      @user = mock_login
      @mod = create(:turing_module, module_number: 2, program: :BE)
      @channel_id = "C02HRH7MF5K" 
      @zoom_meeting_id = 96428502996

      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCurrentAcademicTerm"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term.xml'), headers: {})
      
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295946"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/courses_for_2211.xml'), headers: {})
      
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceStudents", "instance_id"=>"10547831"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/students_for_be2_2211.xml'), headers: {})

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report_for_module_setup.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details_for_module_setup.json'))  

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
        .to_return(body: File.read('spec/fixtures/slack/channel_members_for_module_setup.json'))

      visit turing_module_populi_integration_path(@mod)

      within '#best-match' do
        click_button 'Yes'
      end

      @anthony_b = @mod.students.find_by(name: "Anthony Blackwell Tallent")
      @j = @mod.students.find_by(name: "J Seymour")
      @leo = @mod.students.find_by(name: "Leo Banos Garcia")

      fill_in :slack_channel_id, with: @channel_id
      click_button "Import Channel"

      fill_in :zoom_meeting_id, with: @zoom_meeting_id
      click_button "Import Zoom Accounts From Meeting"
    end
  
    it 'redirects to the account match page' do 
      expect(current_path).to eq(turing_module_account_match_path(@mod))
    end 
    
    it 'has Populi students listed' do
      within "#student-#{@anthony_b.id}" do
        within '.student-name' do 
          expect(page).to have_content(@anthony_b.name)
        end
      end


      @mod.students.each do |student|
        within "#student-#{student.id}" do
          within '.student-name' do 
            expect(page).to have_content(student.name)
          end
        end
      end
    end

    it 'has a select field with the closest matching names from slack ordered by match' do
      within "#student-#{@anthony_b.id}" do
        within '.slack-select' do 
          expect(page).to have_select(selected: "Anthony Blackwell Tallent")
          options = page.all('option')
          expect(options.first.text).to eq("Anthony Blackwell Tallent")
          expect(options[1].text).to eq("Anthony Ongaro")
          expect(options[2].text).to eq("Lucas Colwell")
        end
      end
    
      within "#student-#{@leo.id}" do
        within '.slack-select' do 
          expect(page).to have_select(selected: "Leo Banos Garcia")
          options = page.all('option')
          expect(options.first.text).to eq("Leo Banos Garcia")
          expect(options[1].text).to eq("Mostafa Sakr")
          expect(options[2].text).to eq("Alex Mora BE")
        end
      end
    end

    it 'has a select field with the closest matching name from Zoom' do

      within "#student-#{@anthony_b.id}" do
        within '.zoom-select' do 
          expect(page).to have_select(selected: "Anthony O. BE")
          options = page.all('option')
          expect(options.first.text).to eq("Anthony O. BE")
          expect(options[1].text).to eq("Anhnhi T# BE")
          expect(options[2].text).to eq("Anthony B. (He/Him) BE 2210")
        end
      end
    
      within "#student-#{@leo.id}" do
        within '.zoom-select' do 
          expect(page).to have_select(selected: "Leo BG# BE")
          options = page.all('option')
          expect(options.first.text).to eq("Leo BG# BE")
          expect(options[1].text).to eq("Lacey W (she/her)")
          expect(options[2].text).to eq("Anthony B. (He/Him) BE 2210")
        end
      end
    end

    it 'user can select the correct student if the closest match was wrong' do
      student = @mod.students.find_by(name: "Anthony Blackwell Tallent")
      within "#student-#{student.id}" do
        within '.zoom-select' do 
          select "Anthony B. (He/Him) BE 2210"
        end
        
        within '.slack-select' do 
          select "Anthony Blackwell Tallent"
        end
      end
    end

    it 'user can select Not Present if the student wasnt in the zoom meeting' do
      student = @mod.students.find_by(name: "Anthony Blackwell Tallent")
      within "#student-#{student.id}" do
        within '.zoom-select' do 
          select "Not Present"
        end
      end
      click_button "Match"

      student.reload 

      expect(student.zoom_id).to be_empty
    end

    it 'user can select Not In Channel if the student isnt in the slack channel yet' do
      student = @mod.students.find_by(name: "Anthony Blackwell Tallent")
      within "#student-#{student.id}" do
        within '.slack-select' do 
          select "Not In Channel"
        end
      end
      click_button "Match"

      student.reload 

      expect(student.slack_id).to be_empty
    end

    it 'only includes one option for each uniq zoom name' do
      options = page.first('.zoom-select').all('option').map do |option|
        option.text
      end
      expect(options.uniq.length).to eq(options.length)
    end

    it 'matches the ids for the students' do
      within "#student-#{@anthony_b.id}" do
        within '.zoom-select' do 
          select "Anthony B. (He/Him) BE 2210"
        end
        within '.slack-select' do 
          select "Anthony Blackwell Tallent"
        end
      end
      
      within "#student-#{@j.id}" do
        within '.zoom-select' do 
          select "J Seymour (he/they) BE"
        end
        within '.slack-select' do 
          select "J Seymour"
        end
      end
      
      within "#student-#{@leo.id}" do
        within '.zoom-select' do 
          select "Not Present"
        end
        within '.slack-select' do 
          select "Not In Channel"
        end
      end

      click_button 'Match'
      
      expect(current_path).to eq(turing_module_path(@mod))

      visit turing_module_students_path(@mod)

      within "#student-#{@anthony_b.id}" do
        within '.zoom-id' do
          expect(page).to have_content('79rFGPQZTZyOW9VLTrbQJw')
        end
        
        within '.slack-id' do
          expect(page).to have_content('U035BQEGZ')
        end
        
        within '.populi-id' do
          expect(page).to have_content('24490140')
        end
      end
      
      within "#student-#{@j.id}" do
        within '.zoom-id' do
          expect(page).to have_content('W7NlFRvdQF2lC8KGoYA28A')
        end
        
        within '.slack-id' do
          expect(page).to have_content('U02199TD8SC')
        end
        
        within '.populi-id' do
          expect(page).to have_content('24490161')
        end
      end
      
      within "#student-#{@leo.id}" do
        expect(page.find('.zoom-id').text).to eq('')
        expect(page.find('.slack-id').text).to eq('')
      end
    end
  end
end