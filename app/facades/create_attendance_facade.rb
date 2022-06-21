class CreateAttendanceFacade
  def self.take_attendance(zoom_meeting, turing_module, user, populate_students = false)
    turing_module.create_students_from_participants(zoom_meeting.participant_report) if populate_students
    attendance = turing_module.attendances.create(zoom_meeting_id: zoom_meeting.id, meeting_time: zoom_meeting.start_time, meeting_title: zoom_meeting.title, user: user)

    turing_module.students.each do |student|
      participant = zoom_meeting.participant_report.find {|participant| participant[:id] == student.zoom_id}
      participant_join_time = participant ? Time.parse(participant[:join_time]) : nil
      status = convert_status(participant_join_time, Time.parse(zoom_meeting.start_time))
      StudentAttendance.create(status: status, join_time: participant_join_time, attendance: attendance, student: student)
    end
    attendance
  end

  def self.convert_status(join_time, meeting_start_time)
    return 'absent' if join_time == nil
    minutes_passed_start_time = (join_time - meeting_start_time)/60.0
    return 'absent' if minutes_passed_start_time > 30
    return 'tardy' if minutes_passed_start_time > 1
    return 'present'
  end
end
