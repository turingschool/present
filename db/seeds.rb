user = User.create!(google_id: 'na', email: 'testgmail.com', google_oauth_token: 'na')
inning = Inning.create!(name: "2108")

fe_attendance_spreadsheet = GoogleSpreadsheet.create!(google_id: '1sb75ubr7sTEwB20LdvA940yky9jPdcRq_MvG-zBvSLY')
be_attendance_spreadsheet = GoogleSpreadsheet.create!(google_id: '1DYcKbsZysTT8Boc3hdm4AY0_6518aNK_B9LfyVGhsZ0')
m4_attendance_spreadsheet = GoogleSpreadsheet.create!(google_id: '1hfVjlho0yCeITj1alyC1x6LDtwG0Z0KPyVz-v8pBT3A')

mod4 = inning.turing_modules.create!(program: 'Combined', module_number: 4)
fe1 = inning.turing_modules.create!(program: 'FE', module_number: 1)
fe2 = inning.turing_modules.create!(program: 'FE', module_number: 2)
fe3 = inning.turing_modules.create!(program: 'FE', module_number: 3)
be1 = inning.turing_modules.create!(program: 'BE', module_number: 1)
be2 = inning.turing_modules.create!(program: 'BE', module_number: 2)
be3 = inning.turing_modules.create!(program: 'BE', module_number: 3)

fe1_attendance_sheet = fe_attendance_spreadsheet.google_sheets.create!(google_id: '249481521', name: '2111', turing_module: fe1)
be1_attendance_sheet = be_attendance_spreadsheet.google_sheets.create!(google_id: '1333761590', name: '2111', turing_module: be1)
fe2_attendance_sheet = fe_attendance_spreadsheet.google_sheets.create!(google_id: '1626710953', name: '2110', turing_module: fe2)
be2_attendance_sheet = be_attendance_spreadsheet.google_sheets.create!(google_id: '2021375337', name: '2110', turing_module: be2)
fe3_attendance_sheet = fe_attendance_spreadsheet.google_sheets.create!(google_id: '304214010', name: '2108', turing_module: fe3)
be3_attendance_sheet = be_attendance_spreadsheet.google_sheets.create!(google_id: '567134850', name: '2108', turing_module: be3)
m4_attendance_sheet = m4_attendance_spreadsheet.google_sheets.create!(google_id: '309257798', name: '2107', turing_module: mod4)


fe3.attendances.create!(zoom_meeting_id: 95490216907, meeting_title: 'Cohort Standup', meeting_time: "2021-12-14 16:00:00 UTC", user: user)
fe3.attendances.create!(zoom_meeting_id: 94426586781, meeting_title: 'PD: Alumni Panel', meeting_time: "2021-12-9 20:00:00 UTC", user: user)
fe3.attendances.create!(zoom_meeting_id: 99157739086, meeting_title: 'M4 Gear Up', meeting_time: "2021-12-7 20:00:00 UTC", user: user)
