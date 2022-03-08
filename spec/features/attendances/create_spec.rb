require 'rails_helper'

RSpec.describe 'Creating an Attendance' do
  it 'can fill in a past zoom meeting from the module show page' do
    allow(CreateAttendanceFacade).to receive(:run).and_return(nil)
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
    expected_column = 'AJ'
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
      .with(test_sheet, expected_column, expected_attendance_values, user)

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

    click_link("#{expected_students.length} Students")

    expect(page).to have_css('.student', count: expected_students.length)
    expected_students.each do |student|
      expect(page).to have_content(student.name)
      expect(page).to have_content(student.zoom_email)
      expect(page).to have_content(student.zoom_id)
    end
  end

  it 'creates students attendances'

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
    [
      Student.new(zoom_id: "16778240", name: "Ryan Teske (He/Him)", zoom_email: "ryanteske@outlook.com"),
      Student.new(zoom_id: "16779264", name: "Isika P (she/her# BE)", zoom_email: ""),
      Student.new(zoom_id: "16780288", name: "Natalia ZV (she/her)# FE", zoom_email: "nzamboniv@gmail.com"),
      Student.new(zoom_id: "16781312", name: "Jamie P (she/her)# BE", zoom_email: "jamiejpace@gmail.com"),
      Student.new(zoom_id: "16782336", name: "Tanner D (he/him)# BE", zoom_email: ""),
      Student.new(zoom_id: "16783360", name: "Kevin (he/him)", zoom_email: ""),
      Student.new(zoom_id: "16784384", name: "Weston E# (He/Him)# BE", zoom_email: "ellisweston112@gmail.com"),
      Student.new(zoom_id: "16785408", name: "Carlos G { he: him } FE", zoom_email: "carlosalbertogomez108@gmail.com"),
      Student.new(zoom_id: "16786432", name: "Anna J (she/her)# FE", zoom_email: "ae.johnson2931@gmail.com"),
      Student.new(zoom_id: "16787456", name: "Robbie Jaeger (he/him)", zoom_email: "robbie@turing.io"),
      Student.new(zoom_id: "16788480", name: "Erin Q (she/her)# BE", zoom_email: "equinn125@gmail.com"),
      Student.new(zoom_id: "16789504", name: "Henry S (he/him)# BE", zoom_email: "henry.schmid1@gmail.com"),
      Student.new(zoom_id: "16790528", name: "Ozzie O (he# him) BE", zoom_email: "mikeosmonson@gmail.com"),
      Student.new(zoom_id: "16791552", name: "Nadia N (she/her)", zoom_email: ""),
      Student.new(zoom_id: "16792576", name: "☘️Nolan C.", zoom_email: "nolancaine2@gmail.com"),
      Student.new(zoom_id: "16793600", name: "Brian Zanti (he/him)", zoom_email: "brian@turing.io"),
      Student.new(zoom_id: "16794624", name: "Eric S (he/him)# FE", zoom_email: ""),
      Student.new(zoom_id: "16795648", name: "Joshua H (he/him)# FE", zoom_email: ""),
      Student.new(zoom_id: "16796672", name: "Renee S-Z (She/Her)# FE", zoom_email: ""),
      Student.new(zoom_id: "16797696", name: "Ryan F (he/him)", zoom_email: "ryan@turing.io"),
      Student.new(zoom_id: "16798720", name: "kevinn", zoom_email: ""),
      Student.new(zoom_id: "16799744", name: "Logan V (he/him)", zoom_email: ""),
      Student.new(zoom_id: "16800768", name: "Ezze (He/Him)# BE", zoom_email: "ezzowafai@gmail.com"),
      Student.new(zoom_id: "16801792", name: "Khoi N (he/him) BE", zoom_email: "khoinguyen311@gmail.com"),
      Student.new(zoom_id: "16802816", name: "Travis Rollins (he/him)", zoom_email: "travis@turing.io"),
      Student.new(zoom_id: "16803840", name: "Dane Brophy (he/they)# BE", zoom_email: "dbrophy720@gmail.com"),
      Student.new(zoom_id: "16804864", name: "Paul C", zoom_email: ""),
      Student.new(zoom_id: "16805888", name: "Kelsey T (she/her# BE)", zoom_email: "kelsthompson2@gmail.com"),
      Student.new(zoom_id: "16806912", name: "Anthony I# FE", zoom_email: "anthony.iacono@protonmail.com"),
      Student.new(zoom_id: "16807936", name: "Nate Sheridan (he/him)", zoom_email: "nbs@dr.com"),
      Student.new(zoom_id: "16808960", name: "Raquel H (she/her) FE", zoom_email: ""),
      Student.new(zoom_id: "16809984", name: "Ida O (she/her)# BE", zoom_email: ""),
      Student.new(zoom_id: "16811008", name: "Sami Peterson", zoom_email: "sami.peterson14@gmail.com"),
      Student.new(zoom_id: "16812032", name: "Jacq W. (they/them)", zoom_email: ""),
      Student.new(zoom_id: "16813056", name: "Erika K. (she/her) BE", zoom_email: "erika.kischuk@gmail.com"),
      Student.new(zoom_id: "16814080", name: "Jes Jones (she/her) BE", zoom_email: ""),
      Student.new(zoom_id: "16815104", name: "Rowan (they/them)", zoom_email: "rowanwinzer@gmail.com"),
      Student.new(zoom_id: "16816128", name: "Phil T (he/him)# FE", zoom_email: ""),
      Student.new(zoom_id: "16817152", name: "Sarah Rudy (she/her)# FE", zoom_email: "sarahrudy@gmail.com"),
      Student.new(zoom_id: "16818176", name: "Bei Z (she/her) FE", zoom_email: "241zxy@gmail.com"),
      Student.new(zoom_id: "16819200", name: "Logan V. (he/him) FE", zoom_email: "ldvsimp@gmail.com"),
      Student.new(zoom_id: "16820224", name: "Laura C (she/her)# BE", zoom_email: "laura.mcourt@gmail.com"),
      Student.new(zoom_id: "16821248", name: "Raquel Hill", zoom_email: "")
    ]
  }
end
