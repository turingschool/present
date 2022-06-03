require 'rails_helper'

RSpec.describe 'Student Delete' do
  before(:each) do
    mock_login
  end
  
  it 'deletes a student from the show page' do
    student = create(:student)

    visit student_path(student)

    click_button 'Delete'

    expect(current_path).to eq(turing_module_students_path(student.turing_module))
    expect(page).to_not have_content(student.name)
  end

  it 'deletes the students attendances when the student is deleted' do
    student = create(:student)
    create_list(:student_attendance, 3, student: student)

    visit student_path(student)

    click_button 'Delete'

    expect(current_path).to eq(turing_module_students_path(student.turing_module))
    expect(page).to_not have_content(student.name)
    expect(StudentAttendance.count).to eq(0)
  end
end
