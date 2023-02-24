class CreateAttendanceFacade
  def self.take_attendance(zoom_meeting, turing_module, user, populate_students = false)
    turing_module.create_students_from_participants(zoom_meeting.participants) if populate_students
    attendance = turing_module.attendances.create(user: user)
    ZoomAttendance.create(meeting_time:zoom_meeting.start_time, meeting_title: zoom_meeting.title, zoom_meeting_id: zoom_meeting.id, attendance: attendance)
    take_participant_attendance(attendance, zoom_meeting)
    take_absentee_attendance(attendance, zoom_meeting, turing_module)
    return attendance
  end

  def self.take_slack_attendance(slack_url, turing_module, user)
    channel_id = slack_url.split("/")[-2]
    timestamp = slack_url.split("/").last[1..-1]
    slack_replies_report = SlackService.replies_from_message(channel_id,timestamp)
    attendance_start_time = slack_replies_report[:attendance_start_time].to_datetime
    attendance = turing_module.attendances.create(user: user)
    SlackAttendance.create(channel_id: channel_id, sent_timestamp: Time.at((timestamp.to_i/1000000)).to_datetime, attendance_start_time: attendance_start_time , attendance: attendance)
    present_students = slack_replies_report[:data].map do |reply_info|
      student = Student.find_by(slack_id: reply_info[:slack_id])
      attendance.student_attendances.create(student: student, attendance: attendance, join_time: reply_info[:reply_timestamp], status: reply_info[:status])
      student
    end 
    absent_students = turing_module.students - present_students
    absent_students.each do |student|
      attendance.student_attendances.create(student: student, attendance: attendance, join_time: nil, status: "absent")
    end 
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
    zoom_meeting.participants.each do |participant|
      student = Student.find_or_create_from_participant(participant)
      student_attendance = attendance.student_attendances.find_or_create_by(student: student)
      student_attendance.assign_status(Time.parse(participant.join_time), Time.parse(zoom_meeting.start_time))
    end
  end
end
