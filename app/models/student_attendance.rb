class StudentAttendance < ApplicationRecord
  belongs_to :student
  belongs_to :attendance

  enum status: [:present, :tardy, :absent]

  def self.by_last_name
    joins(:student)
      .select("students.*, student_attendances.*, split_part(students.name, ' ', 2) as last_name")
      .order("last_name")
  end

  def self.by_attendance_status
    joins(:student)
      .select("students.*, student_attendances.*, split_part(students.name, ' ', 2) as last_name")
      .order("status DESC, last_name ASC")
  end

  def visiting_student?
    return true if student.turing_module.nil?
    return true if student.turing_module != self.attendance.turing_module
    return false
  end
end
