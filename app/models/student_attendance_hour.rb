class StudentAttendanceHour < ApplicationRecord
  belongs_to :student_attendance

  enum :status, [:present, :absent]
end