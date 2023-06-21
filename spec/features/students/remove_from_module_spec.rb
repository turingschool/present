require 'rails_helper'

RSpec.describe 'Remove student from module' do
  before(:each) do
    mock_login
  end
  
  it 'Removes student from a module from the show page' do
    student = create(:setup_student)

    visit student_path(student)
    click_button 'Remove from this Module'

    expect(current_path).to eq(student_path(student))
    expect(page).to have_content("Module: none")
    student.reload

    expect(student.turing_module_id).to be_nil
  end
end
