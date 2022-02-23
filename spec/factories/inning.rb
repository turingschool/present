FactoryBot.define do
  factory :inning do
    name { '2107' }

    factory :inning_2107_complete do
      after(:create) do |inning|
        be1 = create(:be1, inning: inning)
        be2 = create(:be2, inning: inning)
        be3 = create(:be3, inning: inning)
        fe1 = create(:fe1, inning: inning)
        fe2 = create(:fe2, inning: inning)
        fe3 = create(:fe3, inning: inning)
        m4 = create(:m4, inning: inning)
        fe_attendance = create(:fe_attendance)
        be_attendance = create(:be_attendance)
        m4_attendance = create(:m4_attendance)
        create(:fe1_attendance_sheet, turing_module: fe1, google_spreadsheet: fe_attendance)
        create(:fe2_attendance_sheet, turing_module: fe2, google_spreadsheet: fe_attendance)
        create(:fe3_attendance_sheet, turing_module: fe3, google_spreadsheet: fe_attendance)
        create(:be1_attendance_sheet, turing_module: be1, google_spreadsheet: be_attendance)
        create(:be2_attendance_sheet, turing_module: be2, google_spreadsheet: be_attendance)
        create(:be3_attendance_sheet, turing_module: be3, google_spreadsheet: be_attendance)
        create(:m4_attendance_sheet, turing_module: m4, google_spreadsheet: m4_attendance)
      end
    end
  end
end
