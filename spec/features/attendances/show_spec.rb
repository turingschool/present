require 'rails_helper'
require './spec/fixtures/populi/test_data/stub_requests.rb'

RSpec.describe 'attendance show page' do
  include ApplicationHelper

  before :each do
    @user = mock_login
    @module = create(:turing_module)
  end

  it 'links to the module and shows attendance date, time, and title' do
    @test_attendance = create(:zoom_attendance)

    visit "/attendances/#{@test_attendance.id}"
    
    expect(page).to have_link(@test_attendance.turing_module.name, href: turing_module_path(@test_attendance.turing_module))
    expect(page).to have_content(@test_attendance.meeting.title)
    expect(page).to have_content(pretty_date(@test_attendance.attendance_time))
    expect(page).to have_content(pretty_time(@test_attendance.attendance_time))
  end

  it "has a link to delete attendance record" do
    test_attendance = create(:zoom_attendance, turing_module: @module)

    visit "/attendances/#{test_attendance.id}"

    expect(page).to have_link("Delete Attendance")
  end

  context "for a Zoom meeting" do
    before(:each) do
      @test_attendance = create(:zoom_attendance)
    end

    it "shows each students name, join time, and status" do
      visit "/attendances/#{@test_attendance.id}"

      within '#student-attendances' do
        @test_attendance.student_attendances.each do |student_attendance|
          within "#student-attendance-#{student_attendance.id}" do
            expect(page).to have_content(student_attendance.status)
            expect(page).to have_content(student_attendance.student.name)
            if student_attendance.join_time
              expect(page).to have_content(pretty_time(student_attendance.join_time))
            else
              expect(page).to have_content("N/A")
            end
          end
        end
      end
    end

    it "students are listed first by Status (absent, tardy, then present), then Name" do 
      student_a = create(:student,  name: "Firstname Alastname", turing_module: @test_attendance.turing_module)
      student_z = create(:student, name: "Firstname Zlastname", turing_module: @test_attendance.turing_module)
      student_b = create(:student, name: "Firstname Blastname", turing_module: @test_attendance.turing_module)
      student_c = create(:student, name: "Firstname Clastname", turing_module: @test_attendance.turing_module)
      create(:student_attendance, student: student_a, status: 'present', attendance: @test_attendance)
      create(:student_attendance, student: student_z, status: 'absent', attendance: @test_attendance)
      create(:student_attendance, student: student_b, status: 'tardy', attendance: @test_attendance)
      create(:student_attendance, student: student_c, status: 'absent', attendance: @test_attendance)
  
      visit attendance_path(@test_attendance)

      expect(student_c.name).to appear_before(student_z.name)
      expect(student_z.name).to appear_before(student_b.name)
      expect(student_b.name).to appear_before(student_a.name)  
    end

    context 'has zoom aliases for students and instructors' do
      it "has a dropdown selector to save a new zoom alias" do
        test_attendance = create(:attendance)
        zoom_meeting_id = test_attendance.meeting.id
        create_list(:student_attendance, 4, attendance: test_attendance, status: :tardy)
        create_list(:student_attendance, 3, attendance: test_attendance, status: :absent)
        create_list(:student_attendance, 7, attendance: test_attendance, status: :present)
        create_list(:zoom_alias, 16, turing_module: test_attendance.turing_module, zoom_meeting: test_attendance.meeting) # 16 because 14 are students and 2 are instructors.

        visit "/attendances/#{test_attendance.id}"

        within '#student-attendances' do
          test_attendance.student_attendances.each do |student_attendance|
            within "#student-attendance-#{student_attendance.id}" do
              expect(test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id).count).to eq(16)
              expect(page).to have_select("student[zoom_alias]", options: test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id).map { |alias_name| alias_name.name })
            end
          end
        end
      end
    end

    context 'can save a zoom alias for student and instructor' do
      before(:each) do
        allow(ZoomService).to receive(:access_token)
        @user = mock_login
        @test_module = create(:setup_module)
        @test_zoom_meeting_id = 95490216907

        stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
        .to_return(body: File.read('spec/fixtures/zoom/participant_report_with_instructors.json'))

        stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
        .to_return(body: File.read('spec/fixtures/zoom/meeting_details_with_instructor.json'))
        
        stub_course_meetings
        stub_enrollments
        stub_create_student_attendance

        visit turing_module_path(@test_module)

        fill_in :attendance_meeting_url, with: "https://turingschool.zoom.us/j/#{@test_zoom_meeting_id}"
    
        click_button 'Take Attendance'

        @attendance = Attendance.last
        @facade = AttendanceShowFacade.new(@attendance)
      end

      it "can save a new zoom alias for a student" do
        within '#student-attendances' do
          student_attendance = @attendance.student_attendances.first
      
          within "#student-attendance-#{student_attendance.id}" do
            expect(@facade.unassigned_zoom_aliases.count).to eq(7)
            expect(page).to have_select("student[zoom_alias]", options: @facade.unassigned_zoom_aliases)
            
            click_button "Save Zoom Alias"
           
            expect(@facade.unassigned_zoom_aliases.count).to eq(6)
          end
        end
      end

      it "can save a new zoom alias as an instructor" do
        expect(page).to have_select("attendance[zoom_alias]", options: @facade.unassigned_zoom_aliases)

        within '.assign_instructor_aliases' do
          expect(@facade.unassigned_zoom_aliases.count).to eq(7)

          select(@facade.unassigned_zoom_aliases[0], from: "attendance[zoom_alias]")
          click_button "Save Zoom Alias As Instructor" 
          
          expect(@facade.unassigned_zoom_aliases.count).to eq(6)
          expect(current_path).to eq(attendance_path(@attendance))
        
          # Assign another zoom alias as an instructor
          select(@facade.unassigned_zoom_aliases[0], from: "attendance[zoom_alias]")
          click_button "Save Zoom Alias As Instructor" 
      
          expect(@facade.unassigned_zoom_aliases.count).to eq(5) 
          expect(current_path).to eq(attendance_path(@attendance))
        end
      end

      it 'Does not display any instructor student objects within the student_attendance table' do
        within '.assign_instructor_aliases' do
          select(@facade.unassigned_zoom_aliases[0], from: "attendance[zoom_alias]")
          click_button "Save Zoom Alias As Instructor" 
        end

        expect(page).to have_content("Instructors Present In Meeting:")
        within '#student-attendances' do
          @facade.student_attendances.each do |student_attendance|
            within "#student-attendance-#{student_attendance.id}" do
              expect(page).to_not have_content("Instructor")
            end
          end
        end
      end
    end

    it 'applies css classes to all students based on status' do
      test_attendance = create(:attendance)
      
      create_list(:student_attendance, 4, attendance: test_attendance, status: :tardy)
      create_list(:student_attendance, 3, attendance: test_attendance, status: :absent)
      create_list(:student_attendance, 7, attendance: test_attendance, status: :present)
      
      visit "/attendances/#{test_attendance.id}"

      within '#student-attendances' do
        tardy = all('.tardy').length
        absent = all('.absent').length
        present = all('.present').length

        expect(tardy).to eq 4
        expect(absent).to eq 3
        expect(present).to eq 7
      end
    end

    it 'shows the meeting id' do
      visit "/attendances/#{@test_attendance.id}"

      expect(page).to have_content("Meeting ID: #{@test_attendance.meeting.meeting_id}")
    end
  end
  
  context "for a Slack Thread" do
    before(:each) do
      @test_attendance = create(:slack_attendance)
    end

    it "shows each students name and attendance status" do
      visit "/attendances/#{@test_attendance.id}"

      within '#student-attendances' do
        @test_attendance.student_attendances.each do |student_attendance|
          within "#student-attendance-#{student_attendance.id}" do
            expect(page).to have_content(student_attendance.status)
            expect(page).to have_content(student_attendance.student.name)
            if student_attendance.join_time
              expect(page).to have_content(pretty_time(student_attendance.join_time))
            else
              expect(page).to have_content("N/A")
            end
          end
        end
      end
    end

    it "students are listed first by Status (absent, tardy, then present), then Name" do
      student_a = create(:student,  name: "Firstname Alastname", turing_module: @test_attendance.turing_module)
      student_z = create(:student, name: "Firstname Zlastname", turing_module: @test_attendance.turing_module)
      student_b = create(:student, name: "Firstname Blastname", turing_module: @test_attendance.turing_module)
      student_c = create(:student, name: "Firstname Clastname", turing_module: @test_attendance.turing_module)
      create(:student_attendance, student: student_a, status: 'present', attendance: @test_attendance)
      create(:student_attendance, student: student_z, status: 'absent', attendance: @test_attendance)
      create(:student_attendance, student: student_b, status: 'tardy', attendance: @test_attendance)
      create(:student_attendance, student: student_c, status: 'absent', attendance: @test_attendance)

      visit attendance_path(@test_attendance)

      expect(student_c.name).to appear_before(student_z.name)
      expect(student_z.name).to appear_before(student_b.name)
      expect(student_b.name).to appear_before(student_a.name)  
    end

    it 'applies css classes to all students based on status' do
      test_attendance = create(:attendance)
      
      create_list(:student_attendance, 4, attendance: test_attendance, status: :tardy)
      create_list(:student_attendance, 3, attendance: test_attendance, status: :absent)
      create_list(:student_attendance, 7, attendance: test_attendance, status: :present)

      visit "/attendances/#{test_attendance.id}"

      within '#student-attendances' do
        tardy = all('.tardy').length
        absent = all('.absent').length
        present = all('.present').length

        expect(tardy).to eq 4
        expect(absent).to eq 3
        expect(present).to eq 7
      end
    end

    it 'shows the message link' do
      visit "/attendances/#{@test_attendance.id}"
      
      expect(page).to have_content("Thread Link: #{@test_attendance.meeting.message_link}")
    end
  end
end
