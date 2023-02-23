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
    expect(find('#student_zoom_id').value).to eq(student.zoom_id)
  end

  it 'can update the students info' do
    student = create(:student)
    new_name = 'Different Name'
    new_zoom_id = '<zoom_id_thats_different>'

    visit edit_student_path(student)

    fill_in :student_name, with: new_name
    fill_in :student_zoom_id, with: new_zoom_id

    click_button 'Save Changes'

    expect(current_path).to eq(student_path(student))
    expect(page).to have_content("Your changes have been saved.")
    expect(page).to have_content(new_name)
  end

  xit 'wont save if changes are invalid' do
    student = create(:student)

    visit edit_student_path(student)

    fill_in :student_zoom_id, with: ''
    click_button 'Save Changes'
    expect(current_path).to eq(edit_student_path(student))
    expect(page).to have_content('Zoom can\'t be blank')
  end

  it 'can update slack id for that user' do 
    test_module = create(:turing_module)
    student = create(:student_with_slack_id, turing_module: test_module)

    create_list(:slack_member, 10, turing_module: test_module)
    slack_member = create(:slack_member, turing_module: test_module, slack_user_id:"new-slack-id")

    visit edit_student_path(student)

    select(slack_member.name)

    click_button 'Save Changes'

    student.reload

    expect(current_path).to eq(student_path(student))
    expect(page).to have_content("Your changes have been saved.")
    expect(student.slack_id).to eq(slack_member.slack_user_id)
    expect(page).to have_content(slack_member.slack_user_id)
  end 
end
