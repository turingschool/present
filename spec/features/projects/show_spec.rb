require 'rails_helper'

RSpec.describe 'pairs show' do
  before(:each) do
    @user = mock_login
    @current_inning = create(:inning, name:'2108', current: true)
    @test_module = create(:backend, inning: @current_inning)
    @user.update(turing_module: @test_module)
  end

  it 'shows Pair groups with group members' do
    @project = create(:project, size: 3)
    students = create_list(:student, 12, turing_module: @test_module)
    @project.generate_student_groupings(students)

    visit "/projects/#{@project.id}"

    expect(page).to have_content(@project.name)
    within('.group-0') do
      within(first('.student-0')) do
        expect(page).to have_content(Group.first.students.first.name)
      end
    end
  end
end
