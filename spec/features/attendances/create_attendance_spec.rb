require 'rails_helper'

RSpec.describe 'Creating an Attendance' do
  it 'can fill in a past zoom meeting from the module show page' do
    allow(AttendanceTaker).to receive(:take_attendance).and_return(nil)
    user = mock_login
    sheet = create(:fe1_attendance_sheet)
    test_module = sheet.turing_module
    test_zoom_meeting_id = 95490216907

    visit turing_module_path(test_module)
    click_link('Take Attendance')
    expect(current_path).to eq("/modules/#{test_module.id}/attendances/new")
    expect(page).to have_content(test_module.name)
    expect(page).to have_content(test_module.inning.name)
    expect(page).to have_content('Take Attendance for a Zoom Meeting')
    fill_in :attendance_zoom_meeting_id, with: test_zoom_meeting_id
    click_button 'Submit'

    expect(current_path).to eq(turing_module_path(test_module))
    within('#past-attendances') do
      expect(page).to have_css('.attendance', count: 1)
      within(first('.attendance')) do
        expect(page).to have_content(test_zoom_meeting_id)
      end
    end
  end

  it 'updates the sheet' do
    user = mock_login
    test_sheet = create(:m4_attendance_sheet)
    test_spreadsheet = test_sheet.google_spreadsheet
    test_module = test_sheet.turing_module
    test_zoom_meeting_id = 97807509963
    # 12/17 am
    # column AJ

    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_participant_report.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_details.json'))

    stub_request(:get, "https://sheets.googleapis.com/v4/spreadsheets/#{test_spreadsheet.google_id}/values/#{test_sheet.name}?majorDimension=COLUMNS") \
      .to_return(body: File.read('spec/fixtures/google_sheet_values.json'))

    stub_request(:put, "https://sheets.googleapis.com/v4/spreadsheets/#{test_spreadsheet.google_id}/values/#{test_sheet.name}?valueInputOption=RAW") \
      .to_return(body: '{}')

    visit turing_module_path(test_module)
    click_link('Take Attendance')
    fill_in :attendance_zoom_meeting_id, with: test_zoom_meeting_id

    expect(GoogleSheetsService).to receive(:update_column) \
      .with(test_sheet, "AJ", expected_attendance_values, user)

    click_button 'Submit'
  end

  it 'will work even if the sheet is resorted in the middle of taking attendance'

  it 'can populate the module with students from the Zoom meeting' do
    user = mock_login
    sheet = create(:fe1_attendance_sheet)
    test_module = sheet.turing_module
    test_zoom_meeting_id = 95490216907
    allow(AttendanceTaker).to receive(:take_attendance).and_return(nil)
    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_participant_report.json'))
    stub_request(:get, "https://api.zoom.us/v2/meetings/#{test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_details.json'))


    visit turing_module_path(test_module)
    expect(page).to have_link('0 Students')
    click_link('Take Attendance')

    check(:attendance_populate_students)
    fill_in :attendance_zoom_meeting_id, with: test_zoom_meeting_id
    click_button 'Submit'

    click_link('23 Students')

    expect(page).to have_css('.student', count: 23)
    expected_students.each do |student|
      expect(page).to have_content(student.name)
      expect(page).to have_content(student.zoom_email)
      expect(page).to have_content(student.zoom_id)
    end
  end

  it 'creates students attendances'

# As a logged in user
# When I visit the show page for a module with no students,
# and I click the button to "Add an Attendance",
# Then I am redirected to the new attendance page
# where I see a check box with a label
# "Use this meeting to add students to your module".
# When I click this checkbox,
# And I add a Zoom meeting id to the text field,
# and I click the submit button,
# Then I am redirected back to the module's show page,
# And I now see a link for '23 Students' (or however many students were in the Zoom meeting)
# And when I click this link I am taken to the module's student index
# where I see the information for each student that was on the Zoom call.

  let(:expected_attendance_values){
    [
      "absent",
      "present",
      "present",
      "present",
      "present",
      "present",
      "present",
      "present",
      "absent",
      "present",
      "present",
      "present",
      "present",
      "present",
      "present",
      "present",
      "tardy",
      "absent",
      "present",
      "tardy",
      "present",
      "present",
      "present",
      "present",
      "present",
      "present",
      "tardy",
      "present",
      "present",
      "absent",
      "absent",
      "present",
      "tardy",
      "present",
      "present",
      "present",
      "present",
      "present",
      "tardy",
      "tardy",
      "present",
      "tardy"
    ]
  }

  let(:expected_students){
    Student.new(name: 'test', zoom_email: 'test', zoom_id: 'test')
  }
end
