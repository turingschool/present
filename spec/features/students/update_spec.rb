require 'rails_helper'

RSpec.describe 'Student Update' do
  before(:each) do
    mock_login
  end
  
  it 'links to the edit page from the show page' do
    student = create(:student)

    visit student_path(student)

    click_link 'Edit'

    expect(current_path).to eq(edit_student_path(student))
  end

  it 'has the students info prepopulated in text boxes' do
    student = create(:student)

    visit edit_student_path(student)

    expect(find('#student_name').value).to eq(student.name)
    expect(find('#student_zoom_email').value).to eq(student.zoom_email)
    expect(find('#student_zoom_id').value).to eq(student.zoom_id)
  end

  it 'can update the students info' do
    student = create(:student)
    new_name = 'Different Name'
    new_zoom_email = 'diff.name@zoom.com'
    new_zoom_id = '<zoom_id_thats_different>'

    visit edit_student_path(student)

    fill_in :student_name, with: new_name
    fill_in :student_zoom_email, with: new_zoom_email
    fill_in :student_zoom_id, with: new_zoom_id

    click_button 'Save Changes'

    expect(current_path).to eq(student_path(student))
    expect(page).to have_content("Your changes have been saved.")
    expect(page).to have_content(new_name)
  end

  it 'wont save if changes are invalid' #student doesn't have any validates at the moment
end
