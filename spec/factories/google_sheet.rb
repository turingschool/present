FactoryBot.define do
  factory :google_sheet do
    google_id { '<google_sheet_id>' }
    name { '<google_sheet_name>' }
    google_spreadsheet
    turing_module

    factory :fe1_attendance_sheet do
      google_id { '249481521' }
      name { '2111' }
      google_spreadsheet factory: :fe_attendance
      turing_module factory: :fe1
    end
  end
end
