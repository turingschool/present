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

end
