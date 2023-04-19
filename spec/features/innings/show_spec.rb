require 'rails_helper'

RSpec.describe "Inning Show Page" do
  before(:each) do 
    @user = mock_login
    @test_inning = create(:inning)
    @my_mod = create(:turing_module, inning: @test_inning)
    @user.update!(turing_module: @my_mod)
    @other_mods = create_list(:turing_module, 3, inning: @test_inning)
    visit inning_path(@test_inning)
  end 

  it 'has a message if module is already set as My Module' do
    within "#turing-module-#{@my_mod.id}" do
      expect(page).to have_content('Currently set as My Module)')
    end
  end

  it 'has a button to set the module as my_module' do
    expect(page).to have_button('Set as My Module', count: 3)
    within "#turing-module-#{@other_mods.second.id}" do
      click_button 'Set as My Module'
    end

    expect(current_path).to eq(inning_path(@test_inning))

    within "#turing-module-#{@other_mods.second.id}" do
      expect(page).to have_content('Currently set as My Module)')
    end
  end
end
