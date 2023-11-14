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
end