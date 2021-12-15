@user = User.create!(google_id: 'na', email: 'test@gmail.com', google_oauth_token: 'na')

@inning = Inning.create!(name: "2108")
@mod4 = @inning.turing_modules.create!(program: 'Combined', module_number: 4, google_spreadsheet_id: '1v3C4DXVmmvV1r7vEuo0Xo58AwAJ-SligrplOiLUjWnw')
@fe1 = @inning.turing_modules.create!(program: 'FE', module_number: 1,google_spreadsheet_id: '10MNyOoYB4w9QCj9y_90DHVUe8DX2OO8ZoGUm8_4suf4', google_sheet_name: "2105")
@fe2 = @inning.turing_modules.create!(program: 'FE', module_number: 2,google_spreadsheet_id: '10MNyOoYB4w9QCj9y_90DHVUe8DX2OO8ZoGUm8_4suf4', google_sheet_name: "2107")
@fe3 = @inning.turing_modules.create!(program: 'FE', module_number: 3,google_spreadsheet_id: '10MNyOoYB4w9QCj9y_90DHVUe8DX2OO8ZoGUm8_4suf4', google_sheet_name: "2108")
@be1 = @inning.turing_modules.create!(program: 'BE', module_number: 1,google_spreadsheet_id: '13jZKWzDx87Epgf_DBOy2k2ilFlJXfJU3MdQ8tqv9HaM', google_sheet_name: "2105")
@be2 = @inning.turing_modules.create!(program: 'BE', module_number: 2,google_spreadsheet_id: '13jZKWzDx87Epgf_DBOy2k2ilFlJXfJU3MdQ8tqv9HaM', google_sheet_name: "2107")
@be3 = @inning.turing_modules.create!(program: 'BE', module_number: 3,google_spreadsheet_id: '13jZKWzDx87Epgf_DBOy2k2ilFlJXfJU3MdQ8tqv9HaM', google_sheet_name: "2108")

@fe3.attendances.create!(zoom_meeting_id: 95490216907, meeting_title: 'Cohort Standup', meeting_time: "2021-12-14 16:00:00 UTC", user: @user)
@fe3.attendances.create!(zoom_meeting_id: 94426586781, meeting_title: 'PD: Alumni Panel', meeting_time: "2021-12-9 20:00:00 UTC", user: @user)
@fe3.attendances.create!(zoom_meeting_id: 99157739086, meeting_title: 'M4 Gear Up', meeting_time: "2021-12-7 20:00:00 UTC", user: @user)
