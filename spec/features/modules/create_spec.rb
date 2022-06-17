require 'rails_helper'

RSpec.describe 'Creating a module' do
  before(:each) do
    user = mock_login
  end

  it 'can create from the inning show page' do
    inning = create(:inning)

    visit inning_path(inning)

    select 'Backend', from: :turing_module_program
    select 3, from: :turing_module_module_number

    click_button 'Create New Module'

    expect(current_path).to eq(inning_path(inning))
    new_mod = TuringModule.last
    expect(new_mod.name).to eq('BE Mod 3')
    expect(page).to have_link(new_mod.name, href: turing_module_path(new_mod))
  end
end
