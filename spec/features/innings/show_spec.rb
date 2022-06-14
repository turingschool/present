require 'rails_helper'

RSpec.describe "Inning Show Page" do
    before(:each) do 
        user = mock_login

        @inning_2107 = create(:inning)
        
        visit inning_path(@inning_2107)
    end 

  it 'user can update inning to current inning' do
    click_button("Set To Current Inning")

    expect(current_path).to eq(inning_path(@inning_2107))

    @inning_2107.reload
    
    expect(@inning_2107.current).to eq(true)
    expect(page).to have_content("(current inning)")
  end

end
