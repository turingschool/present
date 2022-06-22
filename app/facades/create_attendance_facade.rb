class CreateAttendanceFacade
  def self.take_attendance(zoom_meeting, turing_module, user, populate_students = false)


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



    # turing_module.students.each do |student|
    #   participant = zoom_meeting.participant_report.find {|participant| participant[:id] == student.zoom_id}
    #   participant_join_time = participant ? Time.parse(participant[:join_time]) : nil
    #   student_attendance = attendance.student_attendances.find_or_create_by(student: student)
    #   student_attendance.assign_status(participant_join_time, Time.parse(zoom_meeting.start_time))
    # end
    # attendance


    # for each participant
      # if the student does not exist
        # create the student
      # if the student attendance does not exist
        # create a student_attendance
      # assign a status to the student attendance based on the participant
    # for each student in the module
      # If not student attendance was created
        # mark them absent
    turing_module.create_students_from_participants(zoom_meeting.participant_report) if populate_students
    attendance = turing_module.attendances.create(zoom_meeting_id: zoom_meeting.id, meeting_time: zoom_meeting.start_time, meeting_title: zoom_meeting.title, user: user)
    take_participant_attendance(attendance, zoom_meeting)
    take_absentee_attendance(attendance, zoom_meeting, turing_module)
    attendance
  end

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
      student = Student.find_or_create_by(zoom_id: participant[:id])
      student_attendance = attendance.student_attendances.find_or_create_by(student: student)
      student_attendance.assign_status(Time.parse(participant[:join_time]), Time.parse(zoom_meeting.start_time))
    end
  end
end
