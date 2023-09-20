class StudentAttendance < ApplicationRecord
  belongs_to :student
  belongs_to :attendance

  enum status: [:present, :tardy, :absent]

  def self.by_attendance_status
    joins(:student)
      .select("students.*, student_attendances.*, split_part(students.name, ' ', 2) as last_name")
      .order("status DESC, last_name ASC")
  end

  def record_status_for_participant!(participant)
    if self.absent? || self.status.nil? || (self.tardy? && participant.status == "present")
      self.update(status: participant.status, join_time: participant.join_time) 
      return true
    else
      return false
    end
  end
end
