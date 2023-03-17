require 'rails_helper'

RSpec.describe 'Student Update' do
  before(:each) do
    mock_login
  end
  
  it 'links to the edit page from the show page' do
    student = create(:setup_student)

    visit student_path(student)

    click_link 'Edit'

    expect(current_path).to eq(edit_student_path(student))
  end

  it 'has the students info prepopulated in text boxes' do
    student = create(:setup_student)

    visit edit_student_path(student)

    expect(find('#student_name').value).to eq(student.name)
    expect(find('#student_zoom_name').value).to eq(student.zoom_name)
    expect(find('#student_slack_id').value).to eq(student.slack_id)
  end

  it 'can update the students info' do
    student = create(:setup_student)

    new_name = 'Different Name'
    new_zoom_name = 'New Zoom Name'
    new_slack_id = '<slack_id_thats_different>'

    visit edit_student_path(student)

    fill_in :student_name, with: new_name
    fill_in :student_zoom_name, with: new_zoom_name
    fill_in :student_slack_id, with: new_slack_id

    click_button 'Save Changes'

    
    expect(current_path).to eq(student_path(student))
    expect(page).to have_content("Your changes have been saved.")
    expect(page).to have_content(new_name)
    expect(page).to have_content(new_zoom_name)
    expect(page).to have_content(new_slack_id)
  end

  xit 'wont save if changes are invalid' do
    student = create(:student)

    visit edit_student_path(student)

    fill_in :student_zoom_id, with: ''
    click_button 'Save Changes'
    expect(current_path).to eq(edit_student_path(student))
    expect(page).to have_content('Zoom can\'t be blank')
  end

end
