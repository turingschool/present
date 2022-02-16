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

      factory :fe3_attendance_sheet do
        google_id { '304214010' }
        name { '2108' }
        turing_module factory: :fe3
      end
    end

    factory :be_attendance_sheet do
      google_spreadsheet factory: :be_attendance

      factory :be1_attendance_sheet do
        google_id { '1333761590' }
        name { '2111' }
        turing_module factory: :fe1
      end

      factory :be2_attendance_sheet do
        google_id { '2021375337' }
        name { '2110' }
        turing_module factory: :fe2
      end

      factory :be3_attendance_sheet do
        google_id { '567134850' }
        name { '2108' }
        turing_module factory: :fe3
      end
    end
  end
end
