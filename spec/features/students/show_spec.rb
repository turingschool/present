require 'rails_helper'

RSpec.describe 'Student Show Page' do
  it 'is linked from the student index' do
    test_module = create(:fe3)
    students = create_list(:student, 11, turing_module: test_module)

    visit turing_module_students_path(test_module)
    click_link students.first.name

    expect(current_path).to eq("/modules/#{test_module.id}/students/#{students.first.id}")
  end
end
