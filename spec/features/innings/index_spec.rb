require 'rails_helper'

RSpec.describe "Innings Index Page" do
    before(:each) do 
        user = mock_login

        @inning_2107 = create(:inning)
        @inning_2105 = create(:inning, name: '2105')
        @current_inning = create(:inning, name:'2108', current: true)
        
        visit innings_path
    end 

  it 'user can see current inning if there is one' do

    within('.innings-list') do 
        expect(page.all("ul").count).to eq(3)
    end 

    expect(page).to have_content("#{@current_inning.name} (current inning)")
    expect(page).to_not have_content("#{@inning_2105.name} (current inning)")
  end

  it 'innings listed link to their show page' do

    click_link(@inning_2107.name)

    expect(current_path).to eq(inning_path(@inning_2107))
  end

end
