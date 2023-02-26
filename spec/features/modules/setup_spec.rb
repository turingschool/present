require 'rails_helper'

RSpec.describe "Module Setup" do
  before(:each) do
    @user = mock_login
    @mod = create(:turing_module, module_number: 2, program: :BE)

    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCurrentAcademicTerm"}).
      to_return(status: 200, body: File.read('spec/fixtures/current_academic_term.xml'), headers: {})
    
    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295946"}).
      to_return(status: 200, body: File.read('spec/fixtures/courses_for_2211.xml'), headers: {})
    
    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCourseInstanceStudents", "instance_id"=>"10547831"}).
      to_return(status: 200, body: File.read('spec/fixtures/students_for_be2_2211.xml'), headers: {})
  end

  context 'user has not set up mod' do
    it 'has a button to set up mod that goes to populi/new page' do
      visit turing_module_path(@mod)

      click_link('Setup Module')
      
      expect(current_path).to eq(turing_module_populi_integration_path(@mod))
    end

    it 'suggests the best match of module from the list of populi courses' do
      visit turing_module_populi_integration_path(@mod)

      within '#best-match' do
        expect(page).to have_content('BE Mod 2 - Web Application Development')
      end
    end
    
    context 'user confirms Populi module' do
      before :each do
        visit turing_module_populi_integration_path(@mod)

        within '#best-match' do
          click_button 'Yes'
        end
      end

      it 'redirects to slack/new' do
        expect(current_path).to eq(turing_module_slack_integration_path(@mod))
      end

      it 'populates the mod with students' do
        expect(@mod.students.length).to eq(7)
        students = @mod.students.sort_by(&:name)
        expect(@mod.students.second.name).to eq('Anthony Blackwell Tallent')
        expect(@mod.students.second.populi_id).to eq('24490140')
        expect(@mod.students.fifth.name).to eq('J Seymour')
        expect(@mod.students.fifth.populi_id).to eq('24490161')
      end

      context 'and then tries to confirm populi module again' do 
        it 'does not duplicate students in the mod, but rather, replace them' do 
          visit turing_module_populi_integration_path(@mod)

          within '#best-match' do
            click_button 'Yes'
          end
          expect(@mod.students.length).to eq(7)
        end 
      end 

      context 'when a slack channel isnt given' do 
        it 'user is redirected and told to provide a channel id' do 
          mod = create(:turing_module)

          visit turing_module_slack_integration_path(mod)

          fill_in :slack_channel_id, with: ""
          click_button "Import Channel"

          expect(page).to have_content("Please provide a Channel ID")
          expect(page).to have_content("Import Slack Channel")
        end 
      end  

      context 'when a valid slack channel id is given' do 
        before(:each) do
          @channel_id = "C02HRH7MF5K"

          visit turing_module_slack_integration_path(@mod)

          fill_in :slack_channel_id, with: @channel_id
          click_button "Import Channel"
        end

        it 'adds a slack channel to a module' do 
          @mod.reload 

          expect(page).to have_content("Successfully uploaded Channel #{@channel_id}")
          expect(@mod.slack_channel_id).to eq(@channel_id)
        end 

        it 'redirects to the zoom/new page' do
          expect(current_path).to eq(turing_module_zoom_integration_path(@mod))
        end

        context 'when a valid Zoom meeting id is given' do
          before :each do
            @zoom_meeting_id = 96428502996

            stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@zoom_meeting_id}/participants?page_size=300") \
            .to_return(body: File.read('spec/fixtures/participant_report_for_populi.json'))

            stub_request(:get, "https://api.zoom.us/v2/meetings/#{@zoom_meeting_id}") \
            .to_return(body: File.read('spec/fixtures/meeting_details_for_populi.json'))

            stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
            .to_return(body: File.read('spec/fixtures/slack_channel_members_for_module_setup.json'))

            fill_in :zoom_meeting_id, with: @zoom_meeting_id
            click_button "Import Zoom Accounts From Meeting"
          end
          
          it 'redirects to the account match page' do 
            expect(current_path).to eq(turing_module_account_match_path(@mod))
          end 

          it 'has all Populi students listed' do
            @mod.students.each do |student|
              within "#student-#{student.id}" do
                within '.student-name' do 
                  expect(page).to have_content(student.name)
                end
              end
            end
          end

          it 'has a select field with the closest matching name from slack' do
            expected = [
              "Leo Banos Garcia",
              "Anthony Blackwell Tallent",
              "Samuel Cox",
              "Mike Cummins",
              "J Seymour",
              "Anhnhi Tran",
              "Lacey Weaver"
            ]
            @mod.students.each_with_index do |student, index|
              within "#student-#{student.id}" do
                within '.slack-select' do 
                  expect(page).to have_select(selected: expected[index])
                end
              end
            end
          end

          it 'has a select field with the closest matching name from Zoom' do
            expected = [
              "Leo BG# BE",
              "Anthony B. (He/Him) BE 2210",
              "Samuel C (He/Him) BE",
              "Mike C",
              "J Seymour (he/they) BE",
              "Anhnhi T# BE",
              "Lacey W (she/her)"
            ]
            
            @mod.students.each_with_index do |student, index|
              within "#student-#{student.id}" do
                within '.zoom-select' do 
                  skip if index == 1
                  expect(page).to have_select(selected: expected[index])
                end
              end
            end
          end

          it 'user can select the correct student if the closest match was wrong' do
            student = @mod.students.find_by(name: "Anthony Blackwell Tallent")
            within "#student-#{student.id}" do
              within '.zoom-select' do 
                select "Anthony B. (He/Him) BE 2210"
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
            anthony_b = @mod.students.find_by(name: "Anthony Blackwell Tallent")
            j = @mod.students.find_by(name: "J Seymour")

            within "#student-#{anthony_b.id}" do
              within '.zoom-select' do 
                select "Anthony B. (He/Him) BE 2210"
              end
              within '.slack-select' do 
                select "Anthony Blackwell Tallent"
              end
            end
            
            within "#student-#{j.id}" do
              within '.zoom-select' do 
                select "J Seymour (he/they) BE"
              end
              within '.slack-select' do 
                select "J Seymour"
              end
            end

            click_button 'Match'
            
            expect(current_path).to eq(turing_module_path(@mod))

            visit turing_module_students_path(@mod)

            within "#student-#{anthony_b.id}" do
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
            
            within "#student-#{j.id}" do
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
          end
        end
      end 
    end

    context 'when setup isnt fully complete' do 
      before(:each) do 
        @zoom_meeting_id = 96428502996
        @channel_id = "C02HRH7MF5K"

        stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/participant_report_for_populi.json'))

        stub_request(:get, "https://api.zoom.us/v2/meetings/#{@zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/meeting_details_for_populi.json'))

        stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
        .to_return(body: File.read('spec/fixtures/slack_channel_members_for_module_setup.json'))

      end 
      it 'mod show page still prompts for setup if only populi sync complete' do 
        visit turing_module_populi_integration_path(@mod)

        within '#best-match' do
          click_button 'Yes'
        end

        visit turing_module_path(@mod)

        expect(page).to have_link("Setup Module")
        expect(page).to_not have_link("Take Attendance")
      end 

      it 'mod show page still prompts for setup if only populi and slack sync complete' do 
        visit turing_module_populi_integration_path(@mod)

        within '#best-match' do
          click_button 'Yes'
        end

        fill_in :slack_channel_id, with: @channel_id
        click_button "Import Channel"

        visit turing_module_path(@mod)

        expect(page).to have_link("Setup Module")
        expect(page).to_not have_link("Take Attendance")
      end 

      it 'mod show page still prompts for setup if populi, slack, and zoom syncs complete, but match not done' do 
        visit turing_module_populi_integration_path(@mod)

        within '#best-match' do
          click_button 'Yes'
        end

        fill_in :slack_channel_id, with: @channel_id
        click_button "Import Channel"

        fill_in :zoom_meeting_id, with: @zoom_meeting_id
        
        click_button "Import Zoom Accounts From Meeting"

        visit turing_module_path(@mod)

        expect(page).to have_link("Setup Module")
        expect(page).to_not have_link("Take Attendance")
      end 

      it 'mod show page shows link for students and taking attendance once match is done' do 
        visit turing_module_populi_integration_path(@mod)

        within '#best-match' do
          click_button 'Yes'
        end

        fill_in :slack_channel_id, with: @channel_id
        click_button "Import Channel"

        fill_in :zoom_meeting_id, with: @zoom_meeting_id
        
        click_button "Import Zoom Accounts From Meeting"

        click_button "Match"

        visit turing_module_path(@mod)

        expect(page).to_not have_link("Setup Module")
        expect(page).to have_link("Take Attendance")
        expect(page).to have_link("Students (7)")
      end 
      
    end 
  end

  context 'user has set up populi but not slack' do
    it 'links to slack/new'
  end

  context 'user has set up populi and slack but not zoom' do
    it 'links to zoom/new'
  end
end