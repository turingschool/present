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

  it 'displays the students name, zoom id, slack id, and module name' do
    student = create(:student_with_slack_id)

    visit student_path(student)

    expect(page).to have_content(student.name)
    expect(page).to have_content(student.zoom_id)
    expect(page).to have_content(student.slack_id)
    expect(page).to have_content(student.turing_module.name)
  end

  it 'shows that a slack id hasnt been assigned if there is no slack id' do 
    student = create(:student)
    
    visit student_path(student)

    expect(page).to have_content("Not Yet Assigned")
  end 

  it 'the module name is a link' do
    student = create(:student)
    mod = student.turing_module
    
    visit student_path(student)

    expect(page).to have_link(mod.name, href: turing_module_path(mod))
  end
end
