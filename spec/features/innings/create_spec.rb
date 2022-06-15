require 'rails_helper'

RSpec.describe 'Creating a new inning' do
  before(:each) do
    user = mock_login
  end

  it 'can create a new inning from the innings index' do
    visit innings_path

    fill_in :inning_name, with: '2207'
    click_button 'Create Inning'
    new_inning = Inning.last
    expect(new_inning.name).to eq('2207')
    expect(current_path).to eq(inning_path(new_inning))
  end
end
