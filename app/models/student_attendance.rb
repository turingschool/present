class StudentAttendance < ApplicationRecord
  belongs_to :student
  belongs_to :attendance

  enum status: [:present, :tardy, :absent]

  def self.by_attendance_status
    joins(:student)
      .select("students.*, student_attendances.*, split_part(students.name, ' ', 2) as last_name")
      .order("status DESC, last_name ASC")
  end

  def assign_status(status, join_time)
    if self.tardy? && status == "present"
      self.update(status: "present", join_time: join_time)
    elsif self.absent? || self.status.nil?
      self.update(status: status, join_time: join_time) 
    end
  end
end
