require 'rails_helper'

RSpec.describe 'Student Index' do
  before(:each) do
    mock_login
  end

  it 'is linked from the module show page' do
    test_module = create(:setup_module)

    visit turing_module_path(test_module)

    click_link 'Students (6)'

    expect(current_path).to eq("/modules/#{test_module.id}/students")
  end
  
  context "without a slack channel imported" do
    it 'shows the name of the module and all its students' do
      test_module = create(:setup_module)

      visit turing_module_students_path(test_module)

      expect(page).to have_content(test_module.name)
      expect(page).to have_content('Students')

      within('#students') do
        expect(page).to have_css('.student', count: 6)
        test_module.students.each do |student|
          within("#student-#{student.id}") do
            expect(page).to have_content(student.name)
            expect(page).to have_content(student.zoom_name)
          end
        end
      end
    end
  end 

  it 'links to the turing module page' do 
    test_module = create(:setup_module)

    visit turing_module_students_path(test_module)

    click_link(test_module.name)

    expect(current_path).to eq(turing_module_path(test_module))
  end 

end
