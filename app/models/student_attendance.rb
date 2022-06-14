class StudentAttendance < ApplicationRecord
  belongs_to :student
  belongs_to :attendance

  enum status: [:present, :tardy, :absent]

  def self.by_last_name
    joins(:student)
      .select("students.*, student_attendances.*, split_part(students.name, ' ', 2) as last_name")
      .order("last_name")
  end 

end