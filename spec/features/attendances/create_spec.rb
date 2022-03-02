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
end
