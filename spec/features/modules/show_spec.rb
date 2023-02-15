require 'rails_helper'

RSpec.describe 'Modules show page' do
  before(:each) do
    @user = mock_login
  end

  it 'shows the modules attributes' do
    test_module = create(:turing_module)

    visit "/modules/#{test_module.id}"

    expect(page).to have_content("#{test_module.program} Mod #{test_module.module_number}")
    expect(page).to have_content("#{test_module.inning.name} inning")
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

  it "has a link to each attendance's show page" do
    test_module = create(:turing_module)
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

  it 'has a message if module is already set as My Module' do
    mod = create(:turing_module)
    @user.turing_module = mod

    visit turing_module_path(mod)

    expect(page).to have_content('(Set to My Module)')
  end

  it 'has a button to set the module as my_module' do
    mod = create(:turing_module)

    visit turing_module_path(mod)

    click_button 'Set as My Module'

    expect(current_path).to eq(turing_module_path(mod))
    expect(page).to have_content('(Set to My Module)')
    expect(@user.is_this_my_mod?(mod)).to eq(true)
  end

  it 'links to the new Populi Integration page from the mod show page' do
    mod = create(:turing_module)

    visit turing_module_path(mod)
    
    expect(page).to have_link('Integrate with Populi', href: new_turing_module_populi_path(mod))
  end
end
