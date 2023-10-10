require 'rails_helper'

RSpec.describe 'attendance show page' do
  before(:each) do
    @user = mock_login
    @test_module = create(:setup_module)
    @test_zoom_meeting_id = 95490216907

    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report_for_name_matching.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))

    visit turing_module_path(@test_module)

    fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"

    click_button 'Take Attendance'

    @attendance = Attendance.last
  end

  it 'can change an absent student to present using Zoom Alias dropdowns' do
    lacey = @test_module.students.find_by(name: 'Lacey Weaver')

    visit attendance_path(@attendance)
    
    within "#student-#{lacey.id}" do
      expect(page).to have_content("absent")
    end

    within "#student-aliases-#{lacey.id}" do
      expect(first('option').text).to eq("Lacey W (BE, she/her)")
      select("Lacey W (BE, she/her)")
      click_button "Save Zoom Alias"
    end

    expect(current_path).to eq(attendance_path(Attendance.last))
    expect(page).to_not have_css("#student-aliases-#{lacey.id}")
    
    within "#student-#{lacey.id}" do
      expect(page).to have_content("present")
    end
  end

  it 'can change a tardy student to present using Zoom Alias dropdowns' do
    j = @test_module.students.find_by(name: 'J Seymour')

    visit attendance_path(@attendance)

    within "#student-#{j.id}" do
      expect(page).to have_content("tardy")
    end

    within "#student-aliases-#{j.id}" do
      select("J (he/they) BE")
      click_button "Save Zoom Alias"
    end

    within "#student-#{j.id}" do
      expect(page).to have_content("present")
    end
  end

  it 'can change an absent student to tardy using Zoom Alias dropdowns' do
    sam = @test_module.students.find_by(name: 'Samuel Cox')

    visit attendance_path(@attendance)

    within "#student-#{sam.id}" do
      expect(page).to have_content("absent")
    end

    within "#student-aliases-#{sam.id}" do
      expect(first('option').text).to eq("Sam Cox (He/Him) BE")
      select("Sam Cox (He/Him) BE")
      click_button "Save Zoom Alias"
    end

    expect(page).to have_css("#student-aliases-#{sam.id}")

    within "#student-#{sam.id}" do
      expect(page).to have_content("tardy")
    end
  end

  it 'doesnt change status for absent students who joined after 30 minutes' do
    anhnhi = @test_module.students.find_by(name: 'Anhnhi Tran')

    visit attendance_path(@attendance)

    within "#student-#{anhnhi.id}" do
      expect(page).to have_content("absent")
    end
    
    within "#student-aliases-#{anhnhi.id}" do
      expect(first('option').text).to eq("Anhnhi T BE she/her/hers")
      select("Anhnhi T BE she/her/hers")
      click_button "Save Zoom Alias"
    end

    expect(page).to have_css("#student-aliases-#{anhnhi.id}")
    
    within "#student-#{anhnhi.id}" do
      expect(page).to have_content("absent")
    end
  end

  it 'shows the alias used for the student' do
    leo = @test_module.students.find_by(name: "Leo Banos Garcia")
    within "#student-#{leo.id}" do
      within '.alias-used' do
        expect(page).to have_content("Leo BG# BE")
      end
    end
  end

  it 'allows user to undo a zoom alias' do
    leo = @test_module.students.find_by(name: "Leo Banos Garcia")
    zoom_alias = ZoomAlias.find_by(name: "Leo BG# BE")

    within "#student-#{leo.id}" do
      expect(page).to have_content("present")
      click_link leo.name
    end
    
    within '#aliases-used' do
      within "#zoom-alias-#{zoom_alias.id}" do
        expect(page).to have_content(zoom_alias.name)
        click_button "Remove"
      end
    end

    expect(current_path).to eq(student_path(leo))
    expect(page).to_not have_content(zoom_alias.name)

    visit turing_module_path(@test_module)

    fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"

    click_button 'Take Attendance'

    visit attendance_path(Attendance.last)

    within "#student-#{leo.id}" do
      expect(page).to have_content("absent")
    end
  end

  it 'does not create new aliases if that same alias has been used previously in a module\'s meetings'
end
