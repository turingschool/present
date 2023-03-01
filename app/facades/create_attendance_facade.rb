class CreateAttendanceFacade
  attr_reader :meeting, :module, :attendance

  def initialize(meeting, turing_module, user)
    @meeting = meeting
    @module = turing_module
    @attendance = self.module.attendances.create(user: user)
  end

  def run
    ZoomAttendance.create(meeting_time: meeting.start_time, meeting_title: meeting.title, zoom_meeting_id: meeting.id, attendance: attendance)
    take_participant_attendance
    take_absentee_attendance
    update_populi
    return attendance
  end

  def take_slack
    update_populi
  end

  def self.take_attendance(zoom_meeting, turing_module, user)
    new(zoom_meeting, turing_module, user).run  
  end

private
  def populi_service
    @service ||= PopuliService.new
  end

  def populi_meeting
    @populi_meeting ||= retrieve_populi_meeting
  end

  def course_id
    self.module.populi_course_id
  end

  def retrieve_populi_meeting
    # REFACTOR: cache these meetings? update: memozing for now
    data = populi_service.course_meetings(course_id)[:response][:meeting].min_by do |data|
      (meeting.start_time - Time.parse(data[:start])).abs
    end
    PopuliMeeting.new(data)
  end

  def update_populi
    course_id = attendance.turing_module.populi_course_id
    attendance.turing_module.students.each do |student|
      status = attendance.find_status_for_student(student)
      populi_service.update_student_attendance(course_id, populi_meeting.id, student.populi_id, status)
    end
  end

  def take_absentee_attendance
    self.module.students.each do |student|
      unless attendance.student_attendances.find_by(student: student)
        student_attendance = attendance.student_attendances.create(student: student)
        student_attendance.assign_status(nil, populi_meeting.start)
      end
    end
  end

  def take_participant_attendance
    meeting.participants.each do |participant|
      student = Student.find_or_create_from_participant(participant)
      student_attendance = attendance.student_attendances.find_or_create_by(student: student)
      student_attendance.assign_status(Time.parse(participant.join_time), populi_meeting.start)# REPLACE THIS WITH POPULI ATTENDANCE TIMETime.parse(zoom_meeting.start_time))
    end
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
    new(Meeting.new(slack_url, attendance_start_time), turing_module, user).take_slack
    
    return attendance
  end 
end
