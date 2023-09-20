require 'rails_helper'

RSpec.describe 'attendance show page' do
  include ApplicationHelper

  before :each do
    @user = mock_login
  end

  it 'links to the module and shows attendance date, time, and title' do
    @test_attendance = create(:zoom_attendance)

    visit "/attendances/#{@test_attendance.id}"
    
    expect(page).to have_link(@test_attendance.turing_module.name, href: turing_module_path(@test_attendance.turing_module))
    expect(page).to have_content(@test_attendance.meeting.title)
    expect(page).to have_content(pretty_date(@test_attendance.attendance_time))
    expect(page).to have_content(pretty_time(@test_attendance.attendance_time))
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
  end
end
