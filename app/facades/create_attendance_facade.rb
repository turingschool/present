class CreateAttendanceFacade
  def self.take_attendance(zoom_meeting, turing_module, user, populate_students = false)
    turing_module.create_students_from_participants(zoom_meeting.participant_report) if populate_students
    attendance = turing_module.attendances.create(zoom_meeting_id: zoom_meeting.id, meeting_time: zoom_meeting.start_time, meeting_title: zoom_meeting.title, user: user)
    take_participant_attendance(attendance, zoom_meeting)
    take_absentee_attendance(attendance, zoom_meeting, turing_module)
    return attendance
  end

private
  def self.take_absentee_attendance(attendance, zoom_meeting, turing_module)
    turing_module.students.each do |student|
      unless attendance.student_attendances.find_by(student: student)
        student_attendance = attendance.student_attendances.create(student: student)
        student_attendance.assign_status(nil, Time.parse(zoom_meeting.start_time))
      end
    end
  end

  def self.take_participant_attendance(attendance, zoom_meeting)
    zoom_meeting.participant_report.each do |participant|
      student = Student.find_or_create_from_participant(participant)
      student_attendance = attendance.student_attendances.find_or_create_by(student: student)
      student_attendance.assign_status(Time.parse(participant[:join_time]), Time.parse(zoom_meeting.start_time))
    end
  end
end
