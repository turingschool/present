require 'rails_helper'

RSpec.describe "Module Setup Populi Workflow" do
  before(:each) do
    @user = mock_login
    @mod = create(:turing_module, module_number: 2, program: :BE)

    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCurrentAcademicTerm"}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term.xml'), headers: {})
    
    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295946"}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/courses_for_2211.xml'), headers: {})
    
    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getCourseInstanceStudents", "instance_id"=>"10547831"}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/students_for_be2_2211.xml'), headers: {})
    
    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getAcademicTerms"}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/academic_terms.xml'), headers: {})
    
    stub_request(:post, ENV['POPULI_API_URL']).
      with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295898"}).
      to_return(status: 200, body: File.read('spec/fixtures/populi/courses_for_2211.xml'), headers: {})
  end

  it 'suggests the best match of module from the list of populi courses' do
    visit turing_module_populi_integration_path(@mod)

    within '#best-match' do
      expect(page).to have_content('BE Mod 2 - Web Application Development')
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
      expect(@mod.students.fifth.name).to eq('J Seymour')
      expect(@mod.students.fifth.populi_id).to eq('24490161')
      expect(@mod.students.second.name).to eq('Anthony Blackwell Tallent')
      expect(@mod.students.second.populi_id).to eq('24490140')
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