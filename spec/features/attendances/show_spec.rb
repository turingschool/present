require 'rails_helper'

RSpec.describe 'attendance show page' do
  before(:each) do
    @user = mock_login
  end

  it 'links to the module and shows attendance date, time, and Zoom id' do
    test_zoom_attendance = create(:zoom_attendance_with_students)
    test_attendance = test_zoom_attendance.attendance

    student_attendances = test_attendance.student_attendances

    visit "/attendances/#{test_attendance.id}"
    expect(page).to have_link(test_attendance.turing_module.name, href: turing_module_path(test_attendance.turing_module))
    expect(page).to have_content(test_zoom_attendance.meeting_title)
    expect(page).to have_content(test_zoom_attendance.pretty_time)
    expect(page).to have_content(test_zoom_attendance.zoom_meeting_id)
  end

  it "shows each students name, id, and attendance status" do
    test_zoom_attendance = create(:zoom_attendance_with_students)
    test_attendance = test_zoom_attendance.attendance
    student_attendances = test_attendance.student_attendances

    visit "/attendances/#{test_attendance.id}"

    within '#student-attendances' do
      student_attendances.each do |student_attendance|
        within "#student-attendance-#{student_attendance.id}" do
          expect(page).to have_content(student_attendance.status)
          expect(page).to have_content(student_attendance.student.name)
          expect(page).to have_content(student_attendance.student.zoom_id)
        end
      end
    end
  end

  it 'students are listed in alphabetical order by last name' do
    test_module = create(:turing_module)
    student_a = test_module.students.create(zoom_id: "234s234n2l3kj4JkvvA", name: "Firstname Alastname")
    student_z = test_module.students.create(zoom_id: "234sdfsdfaefja;lsdkfjkvvA", name: "Firstname Zlastname")
    student_b = test_module.students.create(zoom_id: "234sdfsdf-lkrj2l34lkn", name: "Firstname Blastname")
    student_c = test_module.students.create(zoom_id: "234sdfsdf-8u90ohvaldkfj", name: "Firstname Clastname")

    attendance = test_module.attendances.create(user: @user)
    attendance.student_attendances.create!(student: student_a, status: 'present')
    attendance.student_attendances.create!(student: student_z, status: 'present')
    attendance.student_attendances.create!(student: student_b, status: 'present')
    attendance.student_attendances.create!(student: student_c, status: 'present')

    visit attendance_path(attendance)

    expect(student_a.name).to appear_before(student_b.name)
    expect(student_b.name).to appear_before(student_c.name)
    expect(student_c.name).to appear_before(student_z.name)
  end


  it "students are listed first by Status (absent, tardy, then present), then Name" do
    test_module = create(:turing_module)
    student_a = test_module.students.create(zoom_id: "234s234n2l3kj4JkvvA", name: "Firstname Alastname")
    student_z = test_module.students.create(zoom_id: "234sdfsdfaefja;lsdkfjkvvA", name: "Firstname Zlastname")
    student_b = test_module.students.create(zoom_id: "234sdfsdf-lkrj2l34lkn", name: "Firstname Blastname")
    student_c = test_module.students.create(zoom_id: "234sdfsdf-8u90ohvaldkfj", name: "Firstname Clastname")
    attendance = test_module.attendances.create(user: @user)
    attendance.student_attendances.create!(student: student_a, status: 'present')
    attendance.student_attendances.create!(student: student_z, status: 'absent')
    attendance.student_attendances.create!(student: student_b, status: 'tardy')
    attendance.student_attendances.create!(student: student_c, status: 'absent')

    visit attendance_path(attendance)

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
