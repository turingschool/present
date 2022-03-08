require 'rails_helper'

RSpec.describe 'Student Index' do
  it 'is linked from the module show page' do
    test_module = create(:fe3)
    create_list(:student, 11, turing_module: test_module)

    visit turing_module_path(test_module)

    click_link '11 Students'

    expect(current_path).to eq("/modules/#{test_module.id}/students")
  end

  it 'shows the name of the module and all its students' do
    test_module = create(:fe3)
    test_students = create_list(:student, 11, turing_module: test_module)

    visit turing_module_students_path(test_module)

    expect(page).to have_content(test_module.name)
    expect(page).to have_content('Students')
    within('#students') do
      expect(page).to have_css('.student', count: 11)
      test_students.each do |student|
        within("#student-#{student.id}") do
          expect(page).to have_content(student.name)
          expect(page).to have_content(student.zoom_email)
          expect(page).to have_content(student.zoom_id)
        end
      end
    end
  end
end