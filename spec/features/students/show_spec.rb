require 'rails_helper'

RSpec.describe 'Student Show Page' do
  before(:each) do
    mock_login
  end
  
  it 'is linked from the student index' do
    test_module = create(:fe3)
    students = create_list(:student, 11, turing_module: test_module)

    visit turing_module_students_path(test_module)
    click_link students.first.name

    expect(current_path).to eq("/students/#{students.first.id}")
  end

  it 'displays the students name, zoom email, and zoom id, and module name' do
    student = create(:student)

    visit student_path(student)

    expect(page).to have_content(student.name)
    expect(page).to have_content(student.zoom_email)
    expect(page).to have_content(student.zoom_id)
    expect(page).to have_content(student.turing_module.name)
  end
end
