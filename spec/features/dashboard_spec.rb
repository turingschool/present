require 'rails_helper'

RSpec.describe "Dashboard" do
  it 'user can see current inning if there is one' do
    user = mock_login

    create(:inning)
    current_inning = create(:inning, name:'2108', current: true)

    visit '/dashboard'

    expect(page).to have_content("Current Inning: #{current_inning.name}")
  end

  it 'user cant see current inning if there isnt one' do
    user = mock_login

    create_list(:inning, 2)

    visit '/dashboard'

    expect(page).to have_content("No Current Inning Selected")
  end

  it 'user can see current modules for the current inning' do 
    user = mock_login
    current_inning = create(:inning, name:'2108', current: true)
    fe_3 = create(:turing_module, program: :FE, module_number: 3, inning_id: current_inning.id)
    fe_1 = create(:turing_module, program: :FE, module_number: 1, inning_id: current_inning.id)
    fe_2 = create(:turing_module, program: :FE, module_number: 2, inning_id: current_inning.id)
    be1 = create(:turing_module, program: :BE, module_number: 1, inning_id: current_inning.id)
    be2 = create(:turing_module, program: :BE, module_number: 2, inning_id: current_inning.id)

    visit dashboard_path

    within(".current-modules") do 
      current_inning.turing_modules.each do |mod|
        expect(page).to have_link("#{mod.program} Mod #{mod.module_number}")
      end 
    end 
    
    click_link("#{fe_3.program} Mod #{fe_3.module_number}")
    expect(current_path).to eq(turing_module_path(fe_3))
  end 


end
