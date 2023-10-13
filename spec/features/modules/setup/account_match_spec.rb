require 'rails_helper'

RSpec.describe "Module Setup Account Matching" do
  context 'user imports students from populi and imports a slack channel' do
    before :each do
      @user = mock_login
      @mod = create(:turing_module, module_number: 2, program: :BE)
      @channel_id = "C02HRH7MF5K" 

      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCurrentAcademicTerm"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term.xml'), headers: {})
      
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295946"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/courses_for_2211.xml'), headers: {})
      
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceStudents", "instance_id"=>"10547831"}).
        to_return(status: 200, body: File.read('spec/fixtures/populi/students_for_be2_2211.xml'), headers: {})

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
    end
  
    it 'redirects to the account match page' do 
      expect(current_path).to eq("/modules/#{@mod.id}/account_match/new")
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
          expect(options[0].text).to eq("Not In Channel")
          expect(options[1].text).to eq("Anthony Blackwell Tallent")
          expect(options[2].text).to eq("Anthony Ongaro")
          expect(options[3].text).to eq("Lucas Colwell")
        end
      end
    
      within "#student-#{@leo.id}" do
        within '.slack-select' do 
          expect(page).to have_select(selected: "Leo Banos Garcia")
          options = page.all('option')
          expect(options[0].text).to eq("Not In Channel")
          expect(options[1].text).to eq("Leo Banos Garcia")
          expect(options[2].text).to eq("Mostafa Sakr")
          expect(options[3].text).to eq("Alex Mora BE")
        end
      end
    end

    xit 'has a select field with the closest matching name from Zoom that is more accurate' do
      within "#student-#{@anthony_b.id}" do
        within '.zoom-select' do 
          expect(page).to have_select(selected: "Anthony B. (He/Him) BE 2210")
          options = page.all('option')
          expect(options[0].text).to eq("Anthony B. (He/Him) BE 2210")
          expect(options[1].text).to eq("Anthony O. BE")
          expect(options[2].text).to eq("Anhnhi T# BE")
        end
      end
    end

    it 'user can make selections and complete account matching' do
      within "#student-#{@anthony_b.id}" do
        within '.slack-select' do 
          select "Anthony Blackwell Tallent"
        end
      end
      
      within "#student-#{@j.id}" do
        within '.slack-select' do 
          select "J Seymour"
        end
      end
      
      within "#student-#{@leo.id}" do
        within '.slack-select' do 
          select "Not In Channel"
        end
      end

      click_button 'Connect Accounts'
      
      expect(current_path).to eq(turing_module_path(@mod))

      visit turing_module_students_path(@mod)
      within "#student-#{@anthony_b.id}" do
        within '.slack-id' do
          expect(page).to have_content('U035BQEGZ')
        end
        
        within '.populi-id' do
          expect(page).to have_content('24490140')
        end
      end

      within "#student-#{@j.id}" do
        within '.slack-id' do
          expect(page).to have_content('U02199TD8SC')
        end
        
        within '.populi-id' do
          expect(page).to have_content('24490161')
        end
      end
      
      within "#student-#{@leo.id}" do
        expect(page.find('.zoom-aliases').text).to eq('')
        expect(page.find('.slack-id').text).to eq('')
      end
    end
  
    it 'displays an error when same account is selected for multiple students' do
      within "#student-#{@anthony_b.id}" do
        within '.slack-select' do 
          select "Anthony Blackwell Tallent"
        end
      end
      
      within "#student-#{@j.id}" do
        within '.slack-select' do 
          select "Anthony Blackwell Tallent"
        end
      end

      click_button 'Connect Accounts'

      expect(page).to have_css('#account-match-table')
      expect(current_path).to eq(new_turing_module_account_match_path(@mod))
      expect(page).to have_content("We're sorry, something isn't quite working. Make sure you are assigning a different Slack User for each student.")
    end
  

    it 'allows the user to select not in channel for multiple students' do
      within "#student-#{@anthony_b.id}" do
        within '.slack-select' do 
          select "Not In Channel"
        end
      end
      
      within "#student-#{@j.id}" do
        within '.slack-select' do 
          select "Not In Channel"
        end
      end

      click_button 'Connect Accounts'

      expect(page).to_not have_content("We're sorry, something isn't quite working. Make sure you are assigning a different Slack User for each student.")
      expect(current_path).to eq(turing_module_path(@mod))
    end

    it 'can correct a mistake if a user selects the wrong slack account for a student' do
      within "#student-#{@anthony_b.id}" do
        within '.slack-select' do 
          select "J Seymour" # User accidentally selects the wrong student
        end
      end
      
      within "#student-#{@j.id}" do
        within '.slack-select' do 
          select "Anthony Blackwell Tallent" # User accidentally selects the wrong student
        end
      end

      click_button 'Connect Accounts'

      click_link "Redo Module Setup"

      within '#best-match' do
        click_button 'Yes'
      end

      fill_in :slack_channel_id, with: @channel_id
      click_button "Import Channel"

      within "#student-#{@anthony_b.id}" do
        within '.slack-select' do 
          select "Anthony Blackwell Tallent"
        end
      end
      
      within "#student-#{@j.id}" do
        within '.slack-select' do 
          select "J Seymour"
        end
      end

      click_button 'Connect Accounts'
      
      expect(page).to_not have_content("We're sorry, something isn't quite working. Make sure you are assigning a different Slack User for each student.")
      expect(current_path).to eq(turing_module_path(@mod))
    end
  end
end