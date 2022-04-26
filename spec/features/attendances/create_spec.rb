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

  xit 'updates the sheet' do
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
      Student.new(zoom_id: "E0WPTrXCQAGkMsvF9rQgQA", name: "Ryan Teske (He/Him)", zoom_email: "ryanteske@outlook.com"),
      Student.new(zoom_id: "lJjq3OXDSKiG5McSVavgpA", name: "Isika P (she/her# BE)", zoom_email: ""),
      Student.new(zoom_id: "wkjK882US_Wn6jcDHRKPyA", name: "Natalia ZV (she/her)# FE", zoom_email: "nzamboniv@gmail.com"),
      Student.new(zoom_id: "Z-b5rLp9QmCAmx1rECjPUA", name: "Jamie P (she/her)# BE", zoom_email: "jamiejpace@gmail.com"),
      Student.new(zoom_id: "kSW_EwppRtSw98z4sF71gQ", name: "Tanner D (he/him)# BE", zoom_email: ""),
      Student.new(zoom_id: "o6yw7uMXQYW4CdkoYNTsnA", name: "Kevin (he/him)", zoom_email: ""),
      Student.new(zoom_id: "u4A9XHYwQxqP7zr_mzla3g", name: "Weston E# (He/Him)# BE", zoom_email: "ellisweston112@gmail.com"),
      Student.new(zoom_id: "QMqKE40eToSF18y0uHFEWQ", name: "Carlos G { he: him } FE", zoom_email: "carlosalbertogomez108@gmail.com"),
      Student.new(zoom_id: "_Yw6s2HCT0StdKHiOXaXCA", name: "Anna J (she/her)# FE", zoom_email: "ae.johnson2931@gmail.com"),
      Student.new(zoom_id: "MUdeK6K_RBOoTu54_xLuNA", name: "Robbie Jaeger (he/him)", zoom_email: "robbie@turing.io"),
      Student.new(zoom_id: "NSqExcyyT7-RFwiheD986w", name: "Erin Q (she/her)# BE", zoom_email: "equinn125@gmail.com"),
      Student.new(zoom_id: "ks0Yw-mxR6yeT2Zi6b11Zw", name: "Henry S (he/him)# BE", zoom_email: "henry.schmid1@gmail.com"),
      Student.new(zoom_id: "6KerLiMKTIO9O330dBhceg", name: "Ozzie O (he# him) BE", zoom_email: "mikeosmonson@gmail.com"),
      Student.new(zoom_id: "N80FSgQ4RWebc79dQY0H9g", name: "Nadia N (she/her)", zoom_email: ""),
      Student.new(zoom_id: "G3C5pxuTQDm3NgKDQ-F4_w", name: "☘️Nolan C.", zoom_email: "nolancaine2@gmail.com"),
      Student.new(zoom_id: "6l6egQjWTgqGzLkNysXciQ", name: "Brian Zanti (he/him)", zoom_email: "brian@turing.io"),
      Student.new(zoom_id: "tuW0wxLdSsSEY8UMxwvZfQ", name: "Eric S (he/him)# FE", zoom_email: ""),
      Student.new(zoom_id: "VBE5V_n_RXWmOazbAZ-LOQ", name: "Joshua H (he/him)# FE", zoom_email: ""),
      Student.new(zoom_id: "AXJsN3EqRKamQeQpWjz3kA", name: "Renee S-Z (She/Her)# FE", zoom_email: ""),
      Student.new(zoom_id: "TNpZEJq2TxKhbqoYl4j01g", name: "Ryan F (he/him)", zoom_email: "ryan@turing.io"),
      Student.new(zoom_id: "nh9R9Fe_Qt2u1DwwwiA0Dw", name: "kevinn", zoom_email: ""),
      Student.new(zoom_id: "KEanb73YQgihvPuS9Tfp1w", name: "Logan V (he/him)", zoom_email: ""),
      Student.new(zoom_id: "y2sNdVGPSUKa0hG8hOfw0Q", name: "Ezze (He/Him)# BE", zoom_email: "ezzowafai@gmail.com"),
      Student.new(zoom_id: "w2MBydrFTLaZna8wH3FZiQ", name: "Khoi N (he/him) BE", zoom_email: "khoinguyen311@gmail.com"),
      Student.new(zoom_id: "sTvg885jQfeUPBCiLefv8Q", name: "Travis Rollins (he/him)", zoom_email: "travis@turing.io"),
      Student.new(zoom_id: "yCdFUkVWSZO2KN5rt1_Evw", name: "Dane Brophy (he/they)# BE", zoom_email: "dbrophy720@gmail.com"),
      Student.new(zoom_id: "I-PHK5qRSD27I5lqPzhGTw", name: "Paul C", zoom_email: ""),
      Student.new(zoom_id: "dHyEMayjSNGVx1yxNMtiNA", name: "Kelsey T (she/her# BE)", zoom_email: "kelsthompson2@gmail.com"),
      Student.new(zoom_id: "OnceRVu1Qn-4vnyeTqBSHA", name: "Anthony I# FE", zoom_email: "anthony.iacono@protonmail.com"),
      Student.new(zoom_id: "ySviBS6iR5qTVwXJ_LDWIg", name: "Nate Sheridan (he/him)", zoom_email: "nbs@dr.com"),
      Student.new(zoom_id: "J5g-w7z2SfK6s_qVuz0gdQ", name: "Raquel H (she/her) FE", zoom_email: ""),
      Student.new(zoom_id: "sA0MNPjDTYKkJ6plhGqH7g", name: "Ida O (she/her)# BE", zoom_email: ""),
      Student.new(zoom_id: "islYw3qxRGiCg3rhoee2gw", name: "Sami Peterson", zoom_email: "sami.peterson14@gmail.com"),
      Student.new(zoom_id: "GVQVBmKXQTmHwXFg2AvbxA", name: "Jacq W. (they/them)", zoom_email: ""),
      Student.new(zoom_id: "4gwWaH-CS7i4oUwXymUNdA", name: "Erika K. (she/her) BE", zoom_email: "erika.kischuk@gmail.com"),
      Student.new(zoom_id: "_Or_fpVCTJ2jrcLLAqvZtQ", name: "Jes Jones (she/her) BE", zoom_email: ""),
      Student.new(zoom_id: "oQH87Yp7T2CP2QvwDFE9yQ", name: "Rowan (they/them)", zoom_email: "rowanwinzer@gmail.com"),
      Student.new(zoom_id: "qixZcwkKR3qLF8eIhJQB6g", name: "Phil T (he/him)# FE", zoom_email: ""),
      Student.new(zoom_id: "I_HbqYdbR7mTSN98awLUVg", name: "Sarah Rudy (she/her)# FE", zoom_email: "sarahrudy@gmail.com"),
      Student.new(zoom_id: "fNJX-t1hQgSlQKSSYLGXOA", name: "Bei Z (she/her) FE", zoom_email: "241zxy@gmail.com"),
      Student.new(zoom_id: "8oidz5nrSpqDbMofdV1jkw", name: "Logan V. (he/him) FE", zoom_email: "ldvsimp@gmail.com"),
      Student.new(zoom_id: "CudREtxyR_e6J0TTPI0pGg", name: "Laura C (she/her)# BE", zoom_email: "laura.mcourt@gmail.com"),
      Student.new(zoom_id: "qhy-A8zjQjKq9mogfJkvvA", name: "Raquel Hill", zoom_email: "")
    ]
  }
end
