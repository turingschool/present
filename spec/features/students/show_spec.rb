require 'rails_helper'

RSpec.describe 'Student Show Page' do
  before(:each) do
    mock_login
  end

  it 'is linked from the student index' do
    test_module = create(:setup_module)
    student = test_module.students.sample

    visit turing_module_students_path(test_module)
    click_link student.name

    expect(current_path).to eq("/students/#{student.id}")
  end

  it 'displays the students name, zoom id, slack id, and module name' do
    test_module = create(:setup_module)
    student = test_module.students.first

    visit student_path(student)

    expect(page).to have_content(student.name)
    expect(page).to have_content(student.zoom_name)
    expect(page).to have_content(student.slack_id)
    expect(page).to have_content(student.turing_module.name)
  end

  it 'shows that a slack id hasnt been assigned if there is no slack id' do 
    test_module = create(:turing_module)
    student = create(:student, turing_module: test_module)

    visit student_path(student)

    expect(page).to have_content("Slack ID: Not Yet Assigned")
  end 

  it 'the module name is a link' do
    test_module = create(:setup_module)
    student = test_module.students.first
    
    visit student_path(student)

    expect(page).to have_link(test_module.name, href: turing_module_path(test_module))
  end
end
