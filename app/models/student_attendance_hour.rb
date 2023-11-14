class StudentAttendanceHour < ApplicationRecord
  belongs_to :student_attendance
  has_one :attendance, through: :student_attendance

  enum :status, [:present, :absent]

  def attendance_type
    self.student_attendance.attendance.meeting_type == "ZoomMeeting" ? "Lesson" : "Lab"
  end

  def check_method
    attendance_type == "Lesson" ? "Zoom" : "Slack"
  end
  
  def self.total(meeting_type: nil, status: nil)
    query = self.all
    query = query.where(attendances: {meeting_type: meeting_type}) if meeting_type
    query = query.where(student_attendance_hours: {status: status}) if status
    query.sum("student_attendance_hours.end_time - student_attendance_hours.start")
  end

  def potential_minutes
    ((self.end_time - self.start) / 60).round
  end
end