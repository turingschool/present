require 'rails_helper'

RSpec.describe 'pairs show' do
  before(:each) do
    @user = mock_login
    @current_inning = create(:inning, name:'2108', current: true)
    @test_module = create(:backend, inning: @current_inning)
    @user.update(turing_module: @test_module)
  end

  it 'shows Pair groups with group members' do
    @project_1 = Project.create(name: 'Some Project Pairing', size: 4)
    visit "/projects/#{@project_1.id}"

    expect(page).to have_content(@project_1.name)
  end
end
