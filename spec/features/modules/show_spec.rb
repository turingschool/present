require 'rails_helper'

RSpec.describe 'Modules show page' do
  it 'shows the modules attributes' do
    test_sheet = create(:google_sheet)
    test_module = test_sheet.turing_module

    visit "/modules/#{test_module.id}"

    expect(page).to have_content("#{test_module.program} Mod #{test_module.module_number}")
    expect(page).to have_content("#{test_module.inning.name} inning")
    expect(page).to have_link('Attendance Sheet', href: test_sheet.link)
    expect(page).to have_content("Calendar Integration: OFF")
  end

  it 'shows the past attendances for the module' do
    sheet = create(:google_sheet)
    test_module = sheet.turing_module

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

  it "has a link to each attendance's show page" do
    sheet = create(:google_sheet)
    test_module = sheet.turing_module
    attendances = create_list(:attendance, 3, turing_module: test_module)
    test_attendance = attendances[1]

    visit "/modules/#{test_module.id}"

    within('#past-attendances') do
      within("#attendance-#{test_attendance.id}") do
        click_link(test_attendance.meeting_title)
        expect(current_path).to eq("/attendances/#{test_attendance.id}")
      end
    end
  end

  it 'shows a message when theres no sheet associated with the module' do
    test_module = create(:turing_module)

    visit "/modules/#{test_module.id}"

    expect(page).to have_content('Attendance Sheet: No Google Sheet associated with this module')
  end
end
