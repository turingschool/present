require 'rails_helper'

RSpec.describe 'attendance show page' do
  it 'shows the module name, attendance date and time' do
    # test_attendance = create(:attendance)
    # students = create_list(:student, 10, turing_module: test_attendance.turing_module)
    # student_attendances = create_list(:student_attendance, 10, attendance: test_attendance)
    test_attendance = create(:attendance_with_students)
    student_attendances = test_attendance.student_attendances

    visit "/modules/#{test_attendance.turing_module.id}/attendances/#{test_attendance.id}"

    expect(page).to have_content(test_attendance.turing_module.name)
    expect(page).to have_content(test_attendance.meeting_title)
    expect(page).to have_content(test_attendance.pretty_time)
  end

  it "shows each students name, email, id, and attendance status" do
    # test_attendance = create(:attendance)
    # students = create_list(:student, 10, turing_module: test_attendance.turing_module)
    # student_attendances = create_list(:student_attendance, 10, attendance: test_attendance)
    test_attendance = create(:attendance_with_students)
    student_attendances = test_attendance.student_attendances

    visit "/modules/#{test_attendance.turing_module.id}/attendances/#{test_attendance.id}"

    within '#student-attendances' do
      student_attendances.each do |student_attendance|
        within "#student-attendance-#{student_attendance.id}" do
          expect(page).to have_content(student_attendance.status)
          expect(page).to have_content(student_attendance.student.name)
          expect(page).to have_content(student_attendance.student.zoom_email)
          expect(page).to have_content(student_attendance.student.zoom_id)
        end
      end
    end
  end
end
