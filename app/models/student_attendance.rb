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

  def assign_status(status)
    if self.tardy? && status == "present"
      self.update(status: "present")
    elsif self.absent? || self.status.nil?
      self.update(status: status) 
    end
  end
end
