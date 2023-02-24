require 'rails_helper'

RSpec.describe 'Populi Integration' do
    before(:each) do
      @user = mock_login
      @mod = create(:turing_module, module_number: 2, program: :BE)
      # @student_1 = create(:student, turing_module: @mod, name: 'Leo BG# BE')
      # @student_2 = create(:student, turing_module: @mod, name: 'Anthony B. (He/Him) BE 2210')
      # @student_3 = create(:student, turing_module: @mod, name: 'Lacey W (she/her)')
      # @student_4 = create(:student, turing_module: @mod, name: 'Anhnhi T# BE')
      # @student_5 = create(:student, turing_module: @mod, name: 'J Seymour (he/they) BE')
      # @student_6 = create(:student, turing_module: @mod, name: 'Mike C. (he/him) BE')
      # @student_7 = create(:student, turing_module: @mod, name: 'Samuel C (He/Him) BE')
      # @students = [@student_1, @student_2, @student_3, @student_4, @student_5, @student_6, @student_7]

      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCurrentAcademicTerm"}).
        to_return(status: 200, body: File.read('spec/fixtures/current_academic_term.xml'), headers: {})
      
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getTermCourseInstances", "term_id"=>"295946"}).
        to_return(status: 200, body: File.read('spec/fixtures/courses_for_2211.xml'), headers: {})
      
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getCourseInstanceStudents", "instance_id"=>"10547831"}).
        to_return(status: 200, body: File.read('spec/fixtures/students_for_be2_2211.xml'), headers: {})
      
      stub_request(:post, ENV['POPULI_API_URL']).
        with(body: {"task"=>"getAcademicTerms"}).
        to_return(status: 200, body: File.read('spec/fixtures/academic_terms.xml'), headers: {})
    end

    it 'suggests the best match of module from the list of populi courses' do
      visit turing_module_populi_integration_path(@mod)

      within '#best-match' do
        expect(page).to have_content('BE Mod 2 - Web Application Development')
      end
    end
    
    context 'user confirms best match' do
      before :each do
        visit turing_module_populi_integration_path(@mod)

        within '#best-match' do
          click_button 'Yes'
        end
      end

      it 'redirects to slack/new' do
        expect(current_path).to eq("/modules/#{@mod.id}/slack/new")
      end

      it 'populates the mod with students' do
        expect(@mod.students.length).to eq(7)
        students = @mod.students.sort_by(&:name)
        expect(@mod.students.second.name).to eq('Anthony Blackwell Tallent')
        expect(@mod.students.second.populi_id).to eq('24490140')
        expect(@mod.students.fifth.name).to eq('J Seymour')
        expect(@mod.students.fifth.populi_id).to eq('24490161')
      end
    end
    
    xit 'user can confirm if the best match is correct and see the students from that course' do
     visit turing_module_populi_integration_path(@mod)

      within '#best-match' do
        click_button 'Yes'
      end

      expect(current_path).to eq("/modules/#{@mod.id}/populi/courses/10547831")
    end

    xcontext 'user confirms their best match' do
      before :each do
        visit turing_module_populi_integration_path(@mod)

        click_button('Yes')
      end

      it 'matches students and assigns populi ids' do
        within "#student-#{@student_1.id}" do
          expect(page).to have_content(@student_1.name)
          select 'Leo Banos Garcia'
        end
        within "#student-#{@student_2.id}" do
          expect(page).to have_content(@student_2.name)
          select 'Anthony C (Anthony) Blackwell Tallent'
        end
        within "#student-#{@student_3.id}" do
          expect(page).to have_content(@student_3.name)
          select 'Janice (Lacey) Weaver'
        end
        within "#student-#{@student_4.id}" do
          expect(page).to have_content(@student_4.name)
          select 'Anhnhi (Anhnhi) Tran'
        end
        within "#student-#{@student_5.id}" do
          expect(page).to have_content(@student_5.name)
          select 'Jake (J) Seymour'
        end
        within "#student-#{@student_6.id}" do
          expect(page).to have_content(@student_6.name)
          select 'MIchael (Mike) Cummins'
        end
        within "#student-#{@student_7.id}" do
          expect(page).to have_content(@student_7.name)
          select 'Samuel (Sam) Cox'
        end

        click_button 'Integrate with Populi'

        expect(current_path).to eq(turing_module_path(@mod))

        click_link 'Students'

        within "#student-#{@student_1.id}" do
          within '.populi_id' do
            expect(page).to have_content(24490130)
          end
        end
        within "#student-#{@student_2.id}" do
          within '.populi_id' do
            expect(page).to have_content(24490140)
          end
        end
        within "#student-#{@student_3.id}" do
          within '.populi_id' do
            expect(page).to have_content(24490100)
          end
        end
        within "#student-#{@student_4.id}" do
          within '.populi_id' do
            expect(page).to have_content(24490062)
          end
        end
        within "#student-#{@student_5.id}" do
          within '.populi_id' do
            expect(page).to have_content(24490161)
          end
        end
        within "#student-#{@student_6.id}" do
          within '.populi_id' do
            expect(page).to have_content(24490150)
          end
        end
        within "#student-#{@student_7.id}" do
          within '.populi_id' do
            expect(page).to have_content(24490123)
          end
        end
      end
    
      it 'pre-selects the closest matching name' do
        within "#student-#{@student_1.id}" do
          expect(page).to have_select(selected: 'Leo Banos Garcia')
        end
        within "#student-#{@student_2.id}" do
          expect(page).to have_select(selected: 'Anthony C (Anthony) Blackwell Tallent')
        end
        within "#student-#{@student_3.id}" do
          expect(page).to have_select(selected: 'Janice (Lacey) Weaver')
        end
        within "#student-#{@student_4.id}" do
          expect(page).to have_select(selected: 'Anhnhi (Anhnhi) Tran')
        end
        within "#student-#{@student_5.id}" do
          expect(page).to have_select(selected: 'Jake (J) Seymour')
        end
        within "#student-#{@student_6.id}" do
          expect(page).to have_select(selected: 'MIchael (Mike) Cummins')
        end
        within "#student-#{@student_7.id}" do
          expect(page).to have_select(selected: 'Samuel (Sam) Cox')
        end
      end

      it 'Will make a best guess if no name matches' do
        Student.destroy_all
        student = create(:student, turing_module: @mod, name: 'Penny Lane')
        refresh
        within "#student-#{student.id}" do
          expect(page).to have_select(selected: 'Janice (Lacey) Weaver')
        end
      end
    end

end