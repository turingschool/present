class CreateAttendanceFacade
  def self.take_attendance(zoom_meeting, turing_module, user, populate_students = false)
    turing_module.create_students_from_participants(zoom_meeting.participant_report) if populate_students
    attendance = turing_module.attendances.create(zoom_meeting_id: zoom_meeting.id, meeting_time: zoom_meeting.start_time, meeting_title: zoom_meeting.title, user: user)
    # attendance.turing_module.students.each do |student|
    #   participants_with_matching_zoom_id = participants.find_all {|participant| participant[:id] == student.zoom_id}
    #   participant = participants_with_matching_zoom_id.first
    #   participant_join_time = participant ? Time.parse(participant[:join_time]) : nil
    #   status = convert_status(participant_join_time, Time.parse(meeting_start_time))
    #   StudentAttendance.create(status: status, join_time: participant_join_time, attendance: attendance, student: student)
    #   participants -= participants_with_matching_zoom_id
    # end
    #
    # participants_with_join_time_status = attatch_status_to_participants(participants,meeting_start_time)
    # attendance.create_visiting_students(participants_with_join_time_status)
    turing_module.students.each do |student|
      participant = zoom_meeting.participant_report.find {|participant| participant[:id] == student.zoom_id}
      participant_join_time = participant ? Time.parse(participant[:join_time]) : nil
      student_attendance = attendance.student_attendances.find_or_create_by(student: student)
      student_attendance.assign_status(participant_join_time, Time.parse(zoom_meeting.start_time))
    end
    attendance
  end



  def self.attatch_status_to_participants(participants, meeting_start_time)
    participants.map do |participant|
      participant[:status] = convert_status(Time.parse(participant[:join_time]), Time.parse(meeting_start_time))
      participant
    end
  end

  def self.convert_status(join_time, meeting_start_time)
    return 'absent' if join_time == nil
    minutes_passed_start_time = (join_time - meeting_start_time)/60
    return 'absent' if minutes_passed_start_time >= 30
    return 'tardy' if 1 <= minutes_passed_start_time
    return 'present'
  end
end
