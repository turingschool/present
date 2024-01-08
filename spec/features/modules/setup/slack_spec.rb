require 'rails_helper'

RSpec.describe "Module Setup Slack Workflow" do
  before(:each) do
    @user = mock_login
    @mod = create(:turing_module, module_number: 2, program: :BE)
    @channel_id = "C02HRH7MF5K"

    stub_request(:get, "https://turing-validation.populi.co/api2/academicterms/current").
         with(headers: {'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}"}).
         to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term.json')) 
    
    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295946"}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/courses_for_2211.xml'), headers: {})
    
    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCourseInstanceStudents", "instance_id"=>"10547831"}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/students_for_be2_2211.xml'), headers: {})

    stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
      .to_return(body: File.read('spec/fixtures/slack/channel_members_for_module_setup.json'))  
  end

  context 'user imports Populi students' do
    before :each do
      visit turing_module_populi_integration_path(@mod)

      within '#best-match' do
        click_button 'Yes'
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
        visit turing_module_slack_integration_path(@mod)

        fill_in :slack_channel_id, with: @channel_id
        click_button "Import Channel"
      end

      it 'adds a slack channel to a module' do 
        @mod.reload 

        expect(@mod.slack_channel_id).to eq(@channel_id)
      end 

      it 'redirects to the zoom/new page' do
        expect(current_path).to eq(new_turing_module_account_match_path(@mod))
      end
    end
  end
end