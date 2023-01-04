class CreateAttendanceFacade
  def self.take_attendance(zoom_meeting, turing_module, user, populate_students = false)
    turing_module.create_students_from_participants(zoom_meeting.participant_report) if populate_students
    # binding.pry
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
    attendance = turing_module.attendances.create(user: user, meeting_time: slack_replies_report[:attendance_start_time])
    turing_module.students.each do |student|
      slack_replies_report
    end
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
