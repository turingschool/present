require 'rails_helper'
require './spec/fixtures/populi/stub_requests.rb'

RSpec.describe "Module Setup Populi Workflow" do
  before(:each) do
    @user = mock_login
    @mod = create(:turing_module, module_number: 2, program: :BE)
    stub_persons
    stub_course_offerings
    stub_academic_terms
    stub_current_academic_term
    stub_course_offerings_by_term
  end

  it 'suggests the best match of module from the list of populi courses' do
    visit turing_module_populi_integration_path(@mod)

    within '#best-match' do
      expect(page).to have_content('BE Mod 2 - Web Application Development')
      expect(page).to have_content('Inning: 2311')
    end
  end

  it 'can get a best match with a launch module' do
    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295946"}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/courses_for_2308.xml'), headers: {})

    launch_mod = create(:turing_module, module_number: 1, program: :Launch)
    visit turing_module_populi_integration_path(launch_mod)

    within '#best-match' do
      expect(page).to have_content('C#.NET Mod 0')
      expect(page).to have_content('Inning: 2311')
    end
  end
  
  context 'user confirms Populi module' do
    before :each do
      visit turing_module_populi_integration_path(@mod)

      within '#best-match' do
        click_button 'Yes'
      end
    end

    it 'redirects to slack/new' do
      expect(current_path).to eq(turing_module_slack_integration_path(@mod))
    end

    it 'populates the mod with students' do
      expect(@mod.students.length).to eq(7)
      students = @mod.students.sort_by(&:name)
      expect(students.third.name).to eq('J Seymour')
      expect(students.third.populi_id).to eq('24490161')
      expect(students.first.name).to eq('Anhnhi Tran')
      expect(students.first.populi_id).to eq('24490062')
    end

    it 'saves the populi course id to the module' do
      @mod.reload
      expect(@mod.populi_course_id).to eq('10547831')
    end

    context 'and then tries to confirm populi module again' do 
      it 'does not duplicate students in the mod, but rather, replace them' do 
        visit turing_module_populi_integration_path(@mod)

        within '#best-match' do
          click_button 'Yes'
        end
        expect(@mod.students.length).to eq(7)
      end 
    end 
  end

  context 'when students exist from a previous module' do
    before :each do
      # Loads students into module (see factories/turing_module.rb)
      # Student "Mike Cummins" is not part of the previous mod, simulating a repeater
      # Student "Samuel Cox" is returned from Populi as "Sam Cox", simulating him changing his name in Populi
      @previous_mod = create(:setup_module)
    end
    
    it 'does not duplicate student records' do
      visit turing_module_populi_integration_path(@mod)

      within '#best-match' do
        # Should create a new student for Mike Cummins, but not Sam Cox
        expect {click_button 'Yes'}.to change{Student.count}.by(1)
      end
    end

    it 'changes the students mod assignments' do
      visit turing_module_populi_integration_path(@mod)

      within '#best-match' do
        click_button 'Yes'
      end

      Student.all.each do |student|
        expect(student.turing_module_id).to eq(@mod.id)
      end
      expect(@mod.students.count).to eq(7)
      expect(@previous_mod.students.count).to eq(0)
    end

    it 'will update the students name' do
      visit turing_module_populi_integration_path(@mod)

      within '#best-match' do
        click_button 'Yes'
      end

      expect(Student.where(name: 'Sam Cox').count).to eq(1)
      expect(Student.where(name: 'Samuel Cox').count).to eq(0)
    end
  end

  context 'User clicks no' do
    it 'user can select their inning and then module' do
      visit turing_module_populi_integration_path(@mod)

      click_button "No"
      
      select("2211")

      click_button("Submit")

      click_button('BE Mod 2 - Web Application Development')

      expect(current_path).to eq(turing_module_slack_integration_path(@mod))
      
      expect(@mod.students.length).to eq(7)
    end
  end
end