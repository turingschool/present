require 'rails_helper'

RSpec.describe "Duration" do
  before(:each) do
    @user = mock_login
    @test_module = create(:setup_module_no_aliases)
    @test_zoom_meeting_id = 95490216907

    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom/participant_report_for_duration.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details_for_duration.json'))

    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))

    visit turing_module_path(@test_module)

    fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"

    click_button 'Take Attendance'

    @attendance = Attendance.last
  end

  it "Duration is 0 for students that don't have a zoom alias yet" do
    lacey = @test_module.students.find_by(name: 'Lacey Weaver')
    visit attendance_path(@attendance)
    
    within "#student-#{lacey.id}" do
      expect(page).to have_content("0")
    end
  end

  it "Duration increases when an alias is assigned" do
    lacey = @test_module.students.find_by(name: 'Lacey Weaver')

    visit attendance_path(@attendance)
    within "#student-#{lacey.id}" do
      expect(page).to have_content("0")
    end

    within "#student-aliases-#{lacey.id}" do
      select("Lacey Weaver")
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id}" do
      expect(page).to have_content("35")
    end

    within "#student-aliases-#{lacey.id}" do
      select("Lacey Weaver (She/Her)")
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id}" do
      expect(page).to have_content("59")
    end
    
    within "#student-aliases-#{lacey.id}" do
      select("Lacey Weaver (She/Her, BE)")
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id}" do
      expect(page).to have_content("63")
    end
  end
  
  it "Duration is not dependent on order zoom aliases are assigned" do
    j = @test_module.students.find_by(name: 'J Seymour')
    visit attendance_path(@attendance)
    
    within "#student-#{j.id}" do
      expect(page).to have_content("0")
    end

    within "#student-aliases-#{j.id}" do
      select("J Seymour (he/they) BE")
      click_button "Save Zoom Alias"
    end

    within "#student-#{j.id}" do
      expect(page).to have_content("21")
    end

    within "#student-aliases-#{j.id}" do
      click_button "Save Zoom Alias"
    end

    within "#student-#{j.id}" do
      select("J (he/they) BE")
      expect(page).to have_content("60")
    end
  end
end