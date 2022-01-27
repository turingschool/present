require 'rails_helper'

RSpec.describe 'Modules show page' do
  it 'shows the modules attriutes' do
    test_module = create(:turing_module)

    visit "/modules/#{test_module.id}"

    expect(page).to have_content("#{test_module.program} Mod #{test_module.module_number}")
    expect(page).to have_content("#{test_module.inning.name} inning")
    expect(page).to have_link(test_module.google_spreadsheet_id)
    expect(page).to have_content("Calendar Integration: OFF")
  end

  it 'shows the past attendances for the module' do
    test_module = create(:turing_module)

    attendances = create_list(:attendance, 3, turing_module: test_module)

    visit "/modules/#{test_module.id}"

    within('#past-attendances') do
      expect(page).to have_content('Past Attendances')
      attendances.each do |attendance|
        within("#attendance-#{attendance.id}") do
          expect(page).to have_content(attendance.meeting_time)
          expect(page).to have_content(attendance.meeting_title)
          expect(page).to have_content(attendance.zoom_meeting_id)
        end
      end
    end
  end
end
