

require 'rails_helper'

RSpec.describe 'Student Create' do
  before(:each) do
    mock_login
  end
  
  it 'links to the create page from the student index' do
    test_module = create(:fe3)
    visit turing_module_students_path(test_module)
    click_link 'Add a Student'
    expect(current_path).to eq("/modules/#{test_module.id}/students/new")
  end

  it 'can create a student' do
    test_module = create(:fe3)
    test_name = 'Alan Turing'
    test_zoom_id = '1234'

    visit new_turing_module_student_path(test_module)

    expect(page).to have_content("Create a new student for #{test_module.name}")

    fill_in :student_name, with: test_name
    fill_in :student_zoom_id, with: test_zoom_id

    click_button 'Create Student'

    expect(current_path).to eq(turing_module_students_path(test_module))
    new_student_id = Student.last.id
    within("#student-#{new_student_id}") do
      expect(page).to have_content(test_name)
      expect(page).to have_content(test_zoom_id)
    end
  end

  # As a logged in User,
  # When I visit a module's student index,
  # And I click a button "Add a Student"
  # then I am redirected to the new student page
  # where I see the module name and a header
  # indicating that I am creating a new student.
  # And I see a form.
  # When I fill in this form with a student's
  # name, zoom email, and zoom id,
  # And I click a button "Add Student"
  # Then I am redirected back to the module's student index
  # And I see the new student I created.
end
