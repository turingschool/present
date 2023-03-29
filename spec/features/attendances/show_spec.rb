require 'rails_helper'

RSpec.describe 'attendance show page' do
  before(:each) do
    @user = mock_login
  end

  it 'links to the module and shows attendance date, time, and Zoom id' do
    test_zoom_attendance = create(:zoom_attendance_with_students)
    test_attendance = test_zoom_attendance.attendance

    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{test_zoom_attendance.zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{test_zoom_attendance.zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

    student_attendances = test_attendance.student_attendances

    visit "/attendances/#{test_attendance.id}"

    expect(page).to have_link(test_attendance.turing_module.name, href: turing_module_path(test_attendance.turing_module))
    expect(page).to have_content(test_zoom_attendance.title)
    expect(page).to have_content(test_attendance.pretty_date)
    expect(page).to have_content(test_attendance.pretty_time)
  end

  it "shows each students name, id, and attendance status" do
    test_zoom_attendance = create(:zoom_attendance_with_students)
    test_attendance = test_zoom_attendance.attendance
    student_attendances = test_attendance.student_attendances

    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{test_zoom_attendance.zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom/participant_report.json'))

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{test_zoom_attendance.zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))

    visit "/attendances/#{test_attendance.id}"

    within '#student-attendances' do
      student_attendances.each do |student_attendance|
        within "#student-attendance-#{student_attendance.id}" do
          expect(page).to have_content(student_attendance.status)
          expect(page).to have_content(student_attendance.student.name)
          expect(page).to have_content(student_attendance.student.zoom_name)
        end
      end
    end
  end

  it "students are listed first by Status (absent, tardy, then present), then Name" do
    zoom_attendance = create(:zoom_attendance)
    attendance = zoom_attendance.attendance
    mod = attendance.turing_module
    student_a = create(:student,  name: "Firstname Alastname", turing_module: mod)
    student_z = create(:student, name: "Firstname Zlastname", turing_module: mod)
    student_b = create(:student, name: "Firstname Blastname", turing_module: mod)
    student_c = create(:student, name: "Firstname Clastname", turing_module: mod)
    create(:student_attendance, student: student_a, status: 'present', attendance: attendance)
    create(:student_attendance, student: student_z, status: 'absent', attendance: attendance)
    create(:student_attendance, student: student_b, status: 'tardy', attendance: attendance)
    create(:student_attendance, student: student_c, status: 'absent', attendance: attendance)

    visit attendance_path(attendance)

    expect(student_c.name).to appear_before(student_z.name)
    expect(student_z.name).to appear_before(student_b.name)
    expect(student_b.name).to appear_before(student_a.name)  
  end

  it 'applies css classes to all students based on status' do
    zoom_attendance = create(:zoom_attendance)
    attendance = zoom_attendance.attendance
    create_list(:student_attendance, 4, attendance: attendance, status: :tardy)
    create_list(:student_attendance, 3, attendance: attendance, status: :absent)
    create_list(:student_attendance, 7, attendance: attendance, status: :present)

    visit "/attendances/#{attendance.id}"

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
