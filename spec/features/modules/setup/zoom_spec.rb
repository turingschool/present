require 'rails_helper'

RSpec.describe "Zoom Setup" do
  it 'displays an error if the meeting is for a personal meeting room' do
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
      .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{@zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details_personal_room.json'))  

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

    expect(page).to have_content("It looks like that Zoom link is for a Personal Meeting Room. You will need to use a unique meeting instead.")
  end
end