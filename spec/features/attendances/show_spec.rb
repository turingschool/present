require 'rails_helper'

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

    context 'has and can save zoom aliases for students and instructors' do
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

      xit "can save a new zoom alias for a student" do
        test_attendance = create(:attendance)
        zoom_meeting_id = test_attendance.meeting.id
        create_list(:student_attendance, 4, attendance: test_attendance, status: :tardy)
        create_list(:student_attendance, 3, attendance: test_attendance, status: :absent)
        create_list(:student_attendance, 7, attendance: test_attendance, status: :present)
        create_list(:zoom_alias, 16, turing_module: test_attendance.turing_module, zoom_meeting: test_attendance.meeting) # 16 because 14 are students and 2 are instructors.
        
        visit "/attendances/#{test_attendance.id}"

        within '#student-attendances' do
          student_attendance = test_attendance.student_attendances.first
      
          within "#student-attendance-#{student_attendance.id}" do
            expect(test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id).count).to eq(16)
            expect(page).to have_select("student[zoom_alias]", options: test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id).map { |alias_name| alias_name.name })
            select(test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id).first.name, from: "student[zoom_alias]")
            
            click_button "Save Zoom Alias" # If this button is clicked, an API call is made durring the attendance.rerecord method in the attendance controller update_zoom_alias.
           
            expect(test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id).count).to eq(15)
          end
        end
      end

      it "can save a new zoom alias as an instructor" do
        test_attendance = create(:attendance)
        zoom_meeting_id = test_attendance.meeting.id
        create_list(:student_attendance, 4, attendance: test_attendance, status: :tardy)
        create_list(:student_attendance, 3, attendance: test_attendance, status: :absent)
        create_list(:student_attendance, 7, attendance: test_attendance, status: :present)
        create_list(:zoom_alias, 16, turing_module: test_attendance.turing_module, zoom_meeting: test_attendance.meeting) # 16 because 14 are students and 2 are instructors.

        visit "/attendances/#{test_attendance.id}"
        
        expect(page).to have_select("attendance[zoom_alias]", options: test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id).map { |alias_name| alias_name.name })

        within '.assign_instructor_aliases' do
          expect(test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id).count).to eq(16)

          select(test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id)[0].name, from: "attendance[zoom_alias]")
          click_button "Save Zoom Alias As Instructor" 
          
          expect(test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id).count).to eq(15)
          expect(current_path).to eq(attendance_path(test_attendance))
        
          # Assign another zoom alias as an instructor
          select(test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id)[0].name, from: "attendance[zoom_alias]")
          click_button "Save Zoom Alias As Instructor" 
      
          expect(test_attendance.turing_module.unclaimed_aliases(zoom_meeting_id).count).to eq(14) 
          expect(current_path).to eq(attendance_path(test_attendance))
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
