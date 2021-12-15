FactoryBot.define do
  factory :google_spreadsheet do
    google_id { '<google_spreadsheet_id>' }

    factory :fe_attendance do
      google_id { '1sb75ubr7sTEwB20LdvA940yky9jPdcRq_MvG-zBvSLY' }
    end

    factory :be_attendance do
      google_id { '1DYcKbsZysTT8Boc3hdm4AY0_6518aNK_B9LfyVGhsZ0' }
    end

    factory :m4_attendance do
      google_id { '1hfVjlho0yCeITj1alyC1x6LDtwG0Z0KPyVz-v8pBT3A' }
    end
  end
end
