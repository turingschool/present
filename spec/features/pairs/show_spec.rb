require 'rails_helper'

RSpec.describe 'pairs show' do
  before(:each) do
    @user = mock_login
    @current_inning = create(:inning, name:'2108', current: true)
    @test_module = create(:backend, inning: @current_inning)
    @user.update(turing_module: @test_module)
  end

  # these tests are dependent upon the existence of a Pair model
  xit 'shows Pair groups with group members' do
    @pair_1 = Pair.create(title: 'Some Project Pairing', group_size: 4)
    visit "/pairs/#{@pair_1.id}"

    expect(page).to have_content(@pair_1.title)
    expect(page).to have_content(@pair_1.group_size)
  end
end
