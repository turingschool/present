require 'rails_helper'

RSpec.describe 'Assign Slack Members To Existing Students' do 
    before(:each) do 
        @user = mock_login
    end 

    it 'updates existing student with a slack id' do 
        test_module = create(:turing_module)

        students = create_list(:student, 8, turing_module: test_module)
        test_student = students.first
        slack_members = create_list(:slack_member, 10, turing_module: test_module)
        test_slack_member = slack_members.second
  
        visit turing_module_students_path(test_module)

        within("#student-#{test_student.id}") do
            select(test_slack_member.name)
            click_button "Connect"
        end

        test_student.reload

        expect(current_path).to eq(turing_module_students_path(test_module))
        expect(test_student.slack_id).to eq(test_slack_member.slack_user_id)

        within("#student-#{test_student.id}") do
            expect(page).to have_content(test_slack_member.slack_user_id)
            expect(page).to_not have_select("slack_id")
        end
    end 
end 
