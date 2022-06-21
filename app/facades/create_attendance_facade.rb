class CreateAttendanceFacade
  def self.take_attendance(zoom_meeting, turing_module, user, populate_students = false)
    turing_module.create_students_from_participants(zoom_meeting.participant_report) if populate_students
    attendance = turing_module.attendances.create(zoom_meeting_id: zoom_meeting.id, meeting_time: zoom_meeting.start_time, meeting_title: zoom_meeting.title, user: user)

    turing_module.students.each do |student|
      participant = zoom_meeting.participant_report.find {|participant| participant[:id] == student.zoom_id}
      participant_join_time = participant ? Time.parse(participant[:join_time]) : nil
      student_attendance = attendance.student_attendances.find_or_create_by(student: student)
      student_attendance.assign_status(participant_join_time, Time.parse(zoom_meeting.start_time))
    end
    attendance
  end
end
