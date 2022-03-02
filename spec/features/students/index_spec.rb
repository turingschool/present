require 'rails_helper'

RSpec.describe 'Student Index' do
  it 'is linked from the module show page' do
    test_module = create(:fe3)
    create_list(:student, 11, turing_module: test_module)

    visit turing_module_path(test_module)

    click_link '11 Students'

    expect(current_path).to eq("/modules/#{test_module.id}/students")
  end
end
