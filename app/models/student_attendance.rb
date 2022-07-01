class StudentAttendance < ApplicationRecord
  belongs_to :student
  belongs_to :attendance

  enum status: [:present, :tardy, :absent]

  def self.by_last_name
    joins(:student)
      .select("students.*, student_attendances.*, split_part(students.name, ' ', 2) as last_name")
      .order("last_name")
  end

  def visiting_student?
    return true if student.turing_module.nil?
    return true if student.turing_module != self.attendance.turing_module
    return false
  end

  def assign_status(join_time, meeting_time)
    if self.join_time.nil? || self.join_time > join_time
      self.update(status: convert_status(join_time, meeting_time), join_time: join_time)
    end
  end

  def convert_status(join_time, meeting_start_time)
    return 'absent' if join_time == nil
    minutes_passed_start_time = (join_time - meeting_start_time)/60.0
    return 'absent' if minutes_passed_start_time > 30
    return 'tardy' if minutes_passed_start_time > 1
    return 'present'
  end
end
