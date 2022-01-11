FactoryBot.define do
  factory :google_sheet do
    google_id { '<google_sheet_id>' }
    name { '<google_sheet_name>' }
    google_spreadsheet
    turing_module

    factory :m4_attendance_sheet do
      google_spreadsheet factory: :m4_attendance
      google_id { '309257798' }
      name { '2107' }
      turing_module factory: :m4
    end

    factory :fe_attendance_sheet do
      google_spreadsheet factory: :fe_attendance

      factory :fe1_attendance_sheet do
        google_id { '249481521' }
        name { '2111' }
        turing_module factory: :fe1
      end

      factory :fe2_attendance_sheet do
        google_id { '1626710953' }
        name { '2110' }
        turing_module factory: :fe2
      end
    end
  end
end
