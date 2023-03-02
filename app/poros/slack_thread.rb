class SlackThread < Meeting
  def initialize(id, start_time)
    super(id, start_time)
  end

  def self.from_message_link(message_url)
    channel_id = message_url.split("/")[-2]
    timestamp = message_url.split("/").last[1..-1]
    slack_replies_report = SlackService.replies_from_message(channel_id,timestamp)
    attendance_start_time = slack_replies_report[:attendance_start_time].to_datetime
    new(message_url, attendance_start_time)
  end
  
  def take_attendance
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
  end
end