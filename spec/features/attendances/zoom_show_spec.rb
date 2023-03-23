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

    # Stub any request to update a student's attendance
    stub_request(:post, ENV['POPULI_API_URL']).         
      with(body: {"instanceID"=>/\d/, "meetingID"=>/\d/, "personID"=>/\d/, "status"=>/TARDY|ABSENT|PRESENT/, "task"=>"updateStudentAttendance"},).
      to_return(status: 200, body: '') 

    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCourseInstanceMeetings", "instanceID"=>@test_module.populi_course_id}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings.xml'))


    visit turing_module_path(@test_module)

    click_link('Take Attendance')

    fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"

    click_button 'Take Attendance'

    @attendance = Attendance.last
  end

  it 'has a dropdown next to absent students' do
    lacey = @test_module.students.find_by(name: 'Lacey Weaver')
    anhnhi = @test_module.students.find_by(name: 'Anhnhi Tran')

    visit attendance_path(@attendance)

    within "#student-aliases-#{lacey.id}" do
      expect(first('option').text).to eq("Lacey W (BE, she/her)")
      select("Lacey W (BE, she/her)")
      click_button "Save Zoom Alias"
    end

    expect(current_path).to eq(attendance_path(Attendance.last))
    
    within "#student-aliases-#{anhnhi.id}" do
      expect(first('option').text).to eq("Anhnhi T BE she/her/hers")
      select("Anhnhi T BE she/her/hers")
      click_button "Save Zoom Alias"
    end

    expect(page).to_not have_css("#student-aliases-#{lacey.id}")
    # Anhnhi is still absent because she joined after 30 mintutes
    expect(page).to have_css("#student-aliases-#{anhnhi.id}")
    
    visit turing_module_students_path(@test_module)

    within "#student-#{anhnhi.id}" do
      within ".zoom-name" do
        expect(page).to have_content("Anhnhi T BE she/her/hers")
      end
    end
    
    within "#student-#{lacey.id}" do
      within ".zoom-name" do
        expect(page).to have_content("Lacey W (BE, she/her)")
      end
    end
  end

  it 'can select zoom aliases for tardy students' do
    j = @test_module.students.find_by(name: 'J Seymour')

    visit attendance_path(@attendance)

    within "#student-aliases-#{j.id}" do
      select("J Seymour")
      click_button "Save Zoom Alias"
    end

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
end
