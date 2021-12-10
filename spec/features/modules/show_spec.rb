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

#   As a logged in user,
# when I visit a Module's show page,
# then I see a heading with the module's name (ex. FE Mod 3)
# and I see the name of the inning listed below the heading
# and I see a link to the Google Sheet that tracks attendance for this mod
# and I see whether or not Calendar Integration is active for this mod.
end
