require 'rails_helper'

RSpec.describe "Duration" do
  before(:each) do
    @user = mock_login
    @test_module = create(:setup_module_no_aliases)
    @test_zoom_meeting_id = 95490216907

    allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token
    
    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom/participant_report_for_duration.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details_for_duration.json'))

    stub_request(:post, ENV['POPULI_API_URL'] || "https://fake-populi-domain.com").
      with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings_for_duration.xml'))

    visit turing_module_path(@test_module)

    fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"

    click_button 'Take Attendance'

    @attendance = Attendance.last
  end

  it "Duration is 0 for students that don't have a zoom alias yet" do
    lacey = @test_module.students.find_by(name: 'Lacey Weaver')
    visit attendance_path(@attendance)
    
    within "#student-#{lacey.id} .duration" do
      expect(page).to have_content("0")
    end
  end

  it "Duration increases when an alias is assigned" do
    lacey = @test_module.students.find_by(name: 'Lacey Weaver')

    visit attendance_path(@attendance)
    within "#student-#{lacey.id} .duration" do
      expect(page).to have_content("0")
    end

    within "#student-aliases-#{lacey.id}" do
      select("Lacey Weaver")
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id} .duration" do
      expect(page).to have_content("33")
    end

    within "#student-aliases-#{lacey.id}" do
      select("Lacey Weaver (She/Her)")
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id} .duration" do
      expect(page).to have_content("57")
    end
    
    within "#student-aliases-#{lacey.id}" do
      select("Lacey Weaver (She/Her, BE)")
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id} .duration" do
      expect(page).to have_content("61")
    end
  end
  
  it "Duration is not dependent on order zoom aliases are assigned" do
    lacey = @test_module.students.find_by(name: 'Lacey Weaver')

    visit attendance_path(@attendance)

    within "#student-#{lacey.id} .duration" do
      expect(page).to have_content("0")
    end

    within "#student-aliases-#{lacey.id}" do
      select("Lacey Weaver (She/Her)")
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id} .duration" do
      expect(page).to have_content("23")
    end

    within "#student-aliases-#{lacey.id}" do
      select("Lacey Weaver (She/Her, BE)")
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id} .duration" do
      expect(page).to have_content("28")
    end

    within "#student-aliases-#{lacey.id}" do
      select("Lacey Weaver")
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id} .duration" do
      expect(page).to have_content("61")
    end
  end

  it 'does not lose precision due to rounding' do
    lacey = @test_module.students.find_by(name: 'Lacey Weaver')

    visit attendance_path(@attendance)

    within "#student-aliases-#{lacey.id}" do
      # Using a different participant for this test. It doesn't matter that this isn't actually Lacey
      # This participant was present for 89 seconds, which rounds down to 1 minute
      select("Calli H.") 
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id} .duration" do
      expect(page).to have_content("1")
    end

    within "#student-aliases-#{lacey.id}" do
      # This participant was also present for 89 seconds
      select("Calli H. 2") 
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id} .duration" do
      # The total duration of 89 + 89 seconds should round up to 3 minutes
      # We should not round both values and then sum then together which would result in a duration of 2 minutes
      expect(page).to have_content("3")
    end
  end

  it 'does not include minutes before the populi attendance start in duration' do
    # Populi attendance start is set to 9:29 in fixture

    lacey = @test_module.students.find_by(name: 'Lacey Weaver')

    visit attendance_path(@attendance)

    within "#student-aliases-#{lacey.id}" do
      # Using a different participant for this test. It doesn't matter that this isn't actually Lacey
      select("Kailey K. 1 (she/her)# BE") 
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id} .duration" do
      # This participant was present from 9:16 - 9:37 giving them a duration of 21 minutes,
      # but attendance doesn't start until 9:29 so they don't get duration for the 13 minutes before attendance starts
      expect(page).to have_content("8")
    end
  end
  
  it 'does not include minutes after the populi attendance end in duration' do
    # Populi attendance start is set to 11:00 in fixture

    lacey = @test_module.students.find_by(name: 'Lacey Weaver')

    visit attendance_path(@attendance)

    within "#student-aliases-#{lacey.id}" do
      # Using a different participant for this test. It doesn't matter that this isn't actually Lacey
      select("Daniel C (he/him)# FE") 
      click_button "Save Zoom Alias"
    end

    within "#student-#{lacey.id} .duration" do
      # This student was present from 10:31 - 11:01 giving them a duration of 30 minutes
      # but the attedance time ends at 11:00 so they don't get duration for that extra minute after the attendance end
      expect(page).to have_content("29")
    end
  end
end